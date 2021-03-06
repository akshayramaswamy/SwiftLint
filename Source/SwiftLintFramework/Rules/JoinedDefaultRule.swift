//
//  JoinedDefaultRule.swift
//  SwiftLint
//
//  Created by Ornithologist Coder on 8/3/17.
//  Copyright © 2017 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct JoinedDefaultParameterRule: ASTRule, ConfigurationProviderRule, OptInRule {
    public var configuration = SeverityConfiguration(.warning)

    public init() {}

    public static let description = RuleDescription(
        identifier: "joined_default_parameter",
        name: "Joined Default Parameter",
        description: "Discouraged explicit usage of the default separator.",
        kind: .idiomatic,
        nonTriggeringExamples: [
            "let foo = bar.joined()",
            "let foo = bar.joined(separator: \",\")",
            "let foo = bar.joined(separator: toto)"
        ],
        triggeringExamples: [
            "let foo = bar.joined(separator: ↓\"\")",
            "let foo = bar.filter(toto)\n" +
            "             .joined(separator: ↓\"\")"
        ]
    )

    public func validate(file: File,
                         kind: SwiftExpressionKind,
                         dictionary: [String: SourceKitRepresentable]) -> [StyleViolation] {
        guard
            kind == .call,
            dictionary.name?.hasSuffix(".joined") == true,
            let defaultSeparatorOffset = defaultSeparatorOffset(dictionary: dictionary, file: file)
            else {
                return []
        }

        return [StyleViolation(ruleDescription: type(of: self).description,
                               severity: configuration.severity,
                               location: Location(file: file, byteOffset: defaultSeparatorOffset))]
    }

    private func defaultSeparatorOffset(dictionary: [String: SourceKitRepresentable], file: File) -> Int? {
        guard
            dictionary.enclosedArguments.count == 1,
            let argument = dictionary.enclosedArguments.first,
            let argumentBodyOffset = argument.bodyOffset,
            let argumentBodyLength = argument.bodyLength,
            argument.name == "separator"
            else {
                return nil
        }

        let body = file.contents.bridge().substringWithByteRange(start: argumentBodyOffset, length: argumentBodyLength)
        return body == "\"\"" ? argumentBodyOffset : nil
    }
}
