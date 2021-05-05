//
//  CombineHelpers.swift
//  PaginationNews
//

//

import Combine
import Foundation
import PaginationNews

extension Publisher {
	func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
		receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
	}
}

extension Publisher {
	func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
		self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
	}
}

extension Publisher {
	func caching(to cache: @escaping ([Article]) -> Void) -> AnyPublisher<Output, Failure> where Output == [Article] {
		handleEvents(receiveOutput: cache).eraseToAnyPublisher()
	}

	func caching(to cache: @escaping (Data) -> Void) -> AnyPublisher<Output, Failure> where Output == Data {
		handleEvents(receiveOutput: cache).eraseToAnyPublisher()
	}
}

public extension LocalArticleImageDataManager {
	typealias Publisher = AnyPublisher<Data, Error>
	struct NoDataError: Error {}

	func loadPublisher(for article: Article) -> Publisher {
		Deferred {
			Future { completion in
				completion(Result {
					guard let data = try self.load(for: article) else {
						throw NoDataError()
					}
					return data
				})
			}
		}
		.eraseToAnyPublisher()
	}
}

public extension LocalArticlesManager {
	typealias Publisher = AnyPublisher<[Article], Error>

	func loadPublisher() -> Publisher {
		Deferred {
			Future { completion in
				completion(Result { try self.load() })
			}
		}
		.eraseToAnyPublisher()
	}
}

extension DispatchQueue {
	static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
		ImmediateWhenOnMainQueueScheduler.shared
	}

	struct ImmediateWhenOnMainQueueScheduler: Scheduler {
		typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
		typealias SchedulerOptions = DispatchQueue.SchedulerOptions

		var now: SchedulerTimeType {
			DispatchQueue.main.now
		}

		var minimumTolerance: SchedulerTimeType.Stride {
			DispatchQueue.main.minimumTolerance
		}

		static let shared = Self()

		private static let key = DispatchSpecificKey<UInt8>()
		private static let value = UInt8.max

		private init() {
			DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
		}

		private func isMainQueue() -> Bool {
			DispatchQueue.getSpecific(key: Self.key) == Self.value
		}

		func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
			guard isMainQueue() else {
				return DispatchQueue.main.schedule(options: options, action)
			}

			action()
		}

		func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
			DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
		}

		func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
			DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
		}
	}
}

extension Scheduler {
	func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
		AnyScheduler(self)
	}
}

typealias AnyDispatchQueueScheduler = AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

extension AnyDispatchQueueScheduler {
	static var immediateOnMainQueue: Self {
		DispatchQueue.immediateWhenOnMainQueueScheduler.eraseToAnyScheduler()
	}
}

struct AnyScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
	private let _now: () -> SchedulerTimeType
	private let _minimumTolerance: () -> SchedulerTimeType.Stride
	private let _schedule: (SchedulerOptions?, @escaping () -> Void) -> Void
	private let _scheduleAfter: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Void
	private let _scheduleAfterInterval: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable

	init<S>(_ scheduler: S) where SchedulerTimeType == S.SchedulerTimeType, SchedulerOptions == S.SchedulerOptions, S: Scheduler {
		_now = { scheduler.now }
		_minimumTolerance = { scheduler.minimumTolerance }
		_schedule = scheduler.schedule(options:_:)
		_scheduleAfter = scheduler.schedule(after:tolerance:options:_:)
		_scheduleAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
	}

	var now: SchedulerTimeType { _now() }

	var minimumTolerance: SchedulerTimeType.Stride { _minimumTolerance() }

	func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
		_schedule(options, action)
	}

	func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
		_scheduleAfter(date, tolerance, options, action)
	}

	func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
		_scheduleAfterInterval(date, interval, tolerance, options, action)
	}
}
