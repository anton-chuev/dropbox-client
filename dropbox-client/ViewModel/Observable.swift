//
//  Observable.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import Foundation

final class Observable<Value> {
    typealias Listener = (Value) -> Void
    private var listener: Listener?
    
    var value: Value {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: Value) {
        self.value = value
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
}
