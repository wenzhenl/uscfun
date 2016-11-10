//
//  OrderedDictionary.swift
//  uscfun
//
//  Created by Wenzheng Li on 11/9/16.
//  Copyright © 2016 Wenzheng Li. All rights reserved.
//

import Foundation

struct OrderedDictionary<KeyType: Hashable, ValueType: Comparable> {
    typealias ArrayType = [KeyType]
    typealias DictionaryType = [KeyType: ValueType]
    
    var keys = ArrayType()
    var dictionary = DictionaryType()
    
    var count: Int {
        return self.keys.count
    }
    
    mutating func removeAll() {
        self.dictionary.removeAll()
        self.keys.removeAll()
    }
    
    subscript(key: KeyType) -> ValueType? {
        get {
            return self.dictionary[key]
        }
        
        set {
            if newValue == nil {
                if let index = self.keys.index(of: key) {
                    self.keys.remove(at: index)
                    self.dictionary[key] = nil
                }
            } else if let index = self.keys.index(of: key) {
                self.keys.remove(at: index)
                self.keys.insert(key, at: insertionIndex(of: newValue!))
                self.dictionary[key] = newValue
            } else {
                self.keys.insert(key, at: insertionIndex(of: newValue!))
                self.dictionary[key] = newValue
            }
        }
    }
    
    private func insertionIndex(of val: ValueType) -> Int {
        var low = 0
        var high = self.count - 1
        
        while low <= high {
            let middle = (low + high) / 2
            if self.dictionary[self.keys[middle]]! < val {
                low = middle + 1
            } else if val < self.dictionary[self.keys[middle]]! {
                high = middle - 1
            } else {
                return middle
            }
        }
        return low
    }
}
