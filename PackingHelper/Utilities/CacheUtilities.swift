//
//  CacheUtilities.swift
//  PackingHelper
//
//  Created by Claude Code on 1/22/26.
//

import Foundation

/// Generic cache wrapper for computed values with time-based invalidation.
/// For use with SwiftData @Transient properties.
final class TransientCache<T> {
    private var cachedValue: T?
    private var lastUpdated: Date = .distantPast

    /// Returns cached value if within TTL (seconds), nil otherwise
    func value(ttl: TimeInterval) -> T? {
        guard cachedValue != nil,
              lastUpdated.distance(to: .now) < ttl else { return nil }
        return cachedValue
    }

    /// Sets new cached value
    func set(_ value: T) {
        cachedValue = value
        lastUpdated = .now
    }

    /// Invalidates the cache
    func invalidate() {
        cachedValue = nil
        lastUpdated = .distantPast
    }
}

enum CacheTTL {
    static let weather: TimeInterval = 3600    // 1 hour
    static let packers: TimeInterval = 30      // 30 seconds
}
