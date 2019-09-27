//
//  PeripherySimple.swift
//  EasyEnglish
//
//  Created by Ihor Mostoviy on 9/11/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import Foundation

struct SomeStruct {
	let a: Int
	let b: Int
}
enum SomeEnum: Int {
	case someCase
}

protocol SomeProtocol { // 'SomeProtocol' is unused
	func someMethod()
	func someUnusedMethod()
	func someMethodWithParam(a: Int)
	func someMethodWithUnusedPara(a: Int)
}
//To make this protocol used declarete variables with it's type

class SomeClass: SomeProtocol {

    private var someDependency: SomeDependency {didSet { print("asdas")} }// writes but never be used

	init(someDependency: SomeDependency) {
		self.someDependency = someDependency
	}

	func someMethod() {
		print("Sample 2")
	}

	func someMethodWithParam(a: Int) {
		fatalError()
		//this param will be ignored cause of fatalError
	}

	func someUnusedMethod() {
		print("Sample 4")
	}

	func someMethodWithUnusedPara(a: Int) {
		print("Sample 5")
	}

	func someFunction(value: Int) {
		if let someCase = SomeEnum(rawValue: value) {
			doSomething(someCase)
		}
	}
	//it will be scaned only in aggresive mode
	//cause someEnum implements protocol RawRepresentable and have some dynamic
	//so pheriphery scans it only in aggresive mode

	func doSomething(_ a: SomeEnum) {
        print("Sample 6 \(a)")
	}
}

class SomeDependency {}

class Execute {
	init() {
		//protocol unused
		let some = SomeClass(someDependency: .init())
		//protocol using
		let someUsingProtocol: SomeProtocol = SomeClass(someDependency: .init())

		some.someMethod()
		someUsingProtocol.someMethod()

		some.someMethodWithParam(a: 1)
		some.someMethodWithUnusedPara(a: 1)
		some.someFunction(value: 1)
	}
}
