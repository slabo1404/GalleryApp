//
//  Array.swift
//  GalleryApp
//
//  Created by Вячеслав Болбат on 5.03.26.
//

extension Array {
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var set = Set<T>()
        return filter { set.insert($0[keyPath: keyPath]).inserted }
    }
}
