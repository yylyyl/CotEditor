//
//  TextFindTests.swift
//  Tests
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2017-02-03.
//
//  ---------------------------------------------------------------------------
//
//  © 2017-2023 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import CotEditor

final class TextFindTests: XCTestCase {
    
    func testTextFinderActions() {
        
        XCTAssertEqual(TextFinder.Action.showFindInterface.rawValue,
                       NSTextFinder.Action.showFindInterface.rawValue)
        XCTAssertEqual(TextFinder.Action.nextMatch.rawValue,
                       NSTextFinder.Action.nextMatch.rawValue)
        XCTAssertEqual(TextFinder.Action.previousMatch.rawValue,
                       NSTextFinder.Action.previousMatch.rawValue)
        XCTAssertEqual(TextFinder.Action.replaceAll.rawValue,
                       NSTextFinder.Action.replaceAll.rawValue)
        XCTAssertEqual(TextFinder.Action.replace.rawValue,
                       NSTextFinder.Action.replace.rawValue)
        XCTAssertEqual(TextFinder.Action.replaceAndFind.rawValue,
                       NSTextFinder.Action.replaceAndFind.rawValue)
        XCTAssertEqual(TextFinder.Action.setSearchString.rawValue,
                       NSTextFinder.Action.setSearchString.rawValue)
        XCTAssertEqual(TextFinder.Action.replaceAllInSelection.rawValue,
                       NSTextFinder.Action.replaceAllInSelection.rawValue)
        XCTAssertEqual(TextFinder.Action.selectAll.rawValue,
                       NSTextFinder.Action.selectAll.rawValue)
        XCTAssertEqual(TextFinder.Action.selectAllInSelection.rawValue,
                       NSTextFinder.Action.selectAllInSelection.rawValue)
        XCTAssertEqual(TextFinder.Action.hideFindInterface.rawValue,
                       NSTextFinder.Action.hideFindInterface.rawValue)
        XCTAssertEqual(TextFinder.Action.showReplaceInterface.rawValue,
                       NSTextFinder.Action.showReplaceInterface.rawValue)
        XCTAssertEqual(TextFinder.Action.showReplaceInterface.rawValue,
                       NSTextFinder.Action.showReplaceInterface.rawValue)
        XCTAssertEqual(TextFinder.Action.hideReplaceInterface.rawValue,
                       NSTextFinder.Action.hideReplaceInterface.rawValue)
    }
    
    
    func testCaptureGroupCount() throws {
        
        var mode: TextFind.Mode
        var textFind: TextFind
        
        mode = .regularExpression(options: [], unescapesReplacement: false)
        
        textFind = try TextFind(for: "", findString: "a", mode: mode)
        XCTAssertEqual(textFind.numberOfCaptureGroups, 0)
        
        textFind = try TextFind(for: "", findString: "(?!=a)(b)(c)(?=d)", mode: mode)
        XCTAssertEqual(textFind.numberOfCaptureGroups, 2)
        
        mode = .textual(options: [], fullWord: false)
        textFind = try TextFind(for: "", findString: "(?!=a)(b)(c)(?=d)", mode: mode)
        XCTAssertEqual(textFind.numberOfCaptureGroups, 0)
    }
    
    
    func testSingleFind() throws {
        
        let text = "abcdefg abcdefg ABCDEFG"
        let findString = "abc"
        
        var textFind: TextFind
        var result: TextFind.FindResult?
        var matches: [NSRange]
        
        textFind = try TextFind(for: text, findString: findString, mode: .textual(options: [], fullWord: false))
        matches = try textFind.matches
        
        result = textFind.find(in: matches, forward: true, wraps: false)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 0, length: 3))
        XCTAssertFalse(result!.wrapped)
        
        result = textFind.find(in: matches, forward: false, wraps: false)
        XCTAssertEqual(matches.count, 2)
        XCTAssertNil(result)
        
        
        textFind = try TextFind(for: text, findString: findString, mode: .textual(options: [], fullWord: false), selectedRanges: [NSRange(location: 1, length: 0)])
        matches = try textFind.matches
        
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 8, length: 3))
        XCTAssertFalse(result!.wrapped)
        
        result = textFind.find(in: matches, forward: false, wraps: true)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 8, length: 3))
        XCTAssertTrue(result!.wrapped)
        
        
        textFind = try TextFind(for: text, findString: findString, mode: .textual(options: .caseInsensitive, fullWord: false), selectedRanges: [NSRange(location: 1, length: 0)])
        matches = try textFind.matches
        
        result = textFind.find(in: matches, forward: false, wraps: true)
        XCTAssertEqual(matches.count, 3)
        XCTAssertEqual(result!.range, NSRange(location: 16, length: 3))
        XCTAssertTrue(result!.wrapped)
    }
    
    
    func testFullWord() throws {
        
        var textFind: TextFind
        var result: TextFind.FindResult?
        var matches: [NSRange]
        
        textFind = try TextFind(for: "apples apple Apple", findString: "apple",
                                mode: .textual(options: .caseInsensitive, fullWord: true))
        matches = try textFind.matches
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 7, length: 5))
        
        textFind = try TextFind(for: "apples apple Apple", findString: "apple",
                                mode: .textual(options: [.caseInsensitive, .literal], fullWord: true))
        matches = try textFind.matches
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 7, length: 5))
        
        textFind = try TextFind(for: "Apfel Äpfel Äpfelchen", findString: "Äpfel",
                                mode: .textual(options: .diacriticInsensitive, fullWord: true))
        matches = try textFind.matches
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 0, length: 5))
        
        textFind = try TextFind(for: "イヌら ｲﾇ イヌ", findString: "イヌ",
                                mode: .textual(options: .widthInsensitive, fullWord: true))
        matches = try textFind.matches
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(result!.range, NSRange(location: 4, length: 2))
    }
    
    
    func testUnescapedRegexFind() throws {
        
        let mode: TextFind.Mode = .regularExpression(options: .caseInsensitive, unescapesReplacement: true)
        let textFind = try TextFind(for: "1", findString: "1", mode: mode, selectedRanges: [NSRange(0..<1)])
        let replacementResult = textFind.replace(with: #"foo：\n1"#)
        XCTAssertEqual(replacementResult!.string, "foo：\n1")
    }
    
    
    func testSingleRegexFindAndReplacement() throws {
        
        let findString = "(?!=a)b(c)(?=d)"
        let mode: TextFind.Mode = .regularExpression(options: .caseInsensitive, unescapesReplacement: true)
        
        var textFind: TextFind
        var result: TextFind.FindResult?
        var matches: [NSRange]
        var replacementResult: ReplacementItem?
        
        
        textFind = try TextFind(for: "abcdefg abcdefg ABCDEFG", findString: findString, mode: mode, selectedRanges: [NSRange(location: 1, length: 1)])
        matches = try textFind.matches
        
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 3)
        XCTAssertEqual(result!.range, NSRange(location: 9, length: 2))
        XCTAssertFalse(result!.wrapped)
        
        result = textFind.find(in: matches, forward: false, wraps: true)
        XCTAssertEqual(matches.count, 3)
        XCTAssertEqual(result!.range, NSRange(location: 17, length: 2))
        XCTAssertTrue(result!.wrapped)
        
        
        textFind = try TextFind(for: "ABCDEFG", findString: findString, mode: mode, selectedRanges: [NSRange(location: 1, length: 1)])
        matches = try textFind.matches
        
        result = textFind.find(in: matches, forward: true, wraps: true)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(result!.range, NSRange(location: 1, length: 2))
        XCTAssertTrue(result!.wrapped)
        
        result = textFind.find(in: matches, forward: false, wraps: true)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(result!.range, NSRange(location: 1, length: 2))
        XCTAssertTrue(result!.wrapped)
        
        replacementResult = textFind.replace(with: "$1")
        XCTAssertNil(replacementResult)
        
        
        textFind = try TextFind(for: "ABCDEFG", findString: findString, mode: mode, selectedRanges: [NSRange(location: 1, length: 2)])
        
        replacementResult = textFind.replace(with: "$1\\t")
        XCTAssertEqual(replacementResult!.string, "C\t")
        XCTAssertEqual(replacementResult!.range, NSRange(location: 1, length: 2))
    }
    
    
    func testFindAll() throws {
        
        let mode: TextFind.Mode = .regularExpression(options: .caseInsensitive, unescapesReplacement: false)
        var textFind: TextFind
        
        textFind = try TextFind(for: "abcdefg ABCDEFG", findString: "(?!=a)b(c)(?=d)", mode: mode)
        
        var matches = [[NSRange]]()
        textFind.findAll { (matchedRanges, _) in
            matches.append(matchedRanges)
        }
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(matches[0].count, 2)
        XCTAssertEqual(matches[0][0], NSRange(location: 1, length: 2))
        XCTAssertEqual(matches[0][1], NSRange(location: 2, length: 1))
        XCTAssertEqual(matches[1].count, 2)
        XCTAssertEqual(matches[1][0], NSRange(location: 9, length: 2))
        XCTAssertEqual(matches[1][1], NSRange(location: 10, length: 1))
        
        
        textFind = try TextFind(for: "abcdefg ABCDEFG", findString: "ab", mode: mode)
        
        matches = [[NSRange]]()
        textFind.findAll { (matchedRanges, _) in
            matches.append(matchedRanges)
        }
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(matches[0].count, 1)
        XCTAssertEqual(matches[0][0], NSRange(location: 0, length: 2))
        XCTAssertEqual(matches[1].count, 1)
        XCTAssertEqual(matches[1][0], NSRange(location: 8, length: 2))
    }
    
    
    func testReplaceAll() throws {
        
        var textFind: TextFind
        var replacementItems: [ReplacementItem]
        var selectedRanges: [NSRange]?
        
        textFind = try TextFind(for: "abcdefg ABCDEFG", findString: "(?!=a)b(c)(?=d)",
                                mode: .regularExpression(options: .caseInsensitive, unescapesReplacement: false))
        
        (replacementItems, selectedRanges) = textFind.replaceAll(with: "$1\\\\t") { (_, _, _)  in }
        XCTAssertEqual(replacementItems.count, 1)
        XCTAssertEqual(replacementItems[0].string, "ac\\tdefg AC\\tDEFG")
        XCTAssertEqual(replacementItems[0].range, NSRange(location: 0, length: 15))
        XCTAssertNil(selectedRanges)
        
        
        textFind = try TextFind(for: "abcdefg abcdefg abcdefg", findString: "abc",
                                mode: .regularExpression(options: [], unescapesReplacement: false),
                                inSelection: true,
                                selectedRanges: [NSRange(location: 1, length: 14),
                                                 NSRange(location: 16, length: 7)])
        
        (replacementItems, selectedRanges) = textFind.replaceAll(with: "_") { (_, _, _)  in }
        XCTAssertEqual(replacementItems.count, 2)
        XCTAssertEqual(replacementItems[0].string, "bcdefg _defg")
        XCTAssertEqual(replacementItems[0].range, NSRange(location: 1, length: 14))
        XCTAssertEqual(replacementItems[1].string, "_defg")
        XCTAssertEqual(replacementItems[1].range, NSRange(location: 16, length: 7))
        XCTAssertEqual(selectedRanges![0], NSRange(location: 1, length: 12))
        XCTAssertEqual(selectedRanges![1], NSRange(location: 14, length: 5))
    }
}
