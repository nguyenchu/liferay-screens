/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
import XCTest
import UIKit


class DDLFieldDocument_Tests: XCTestCase {

	private let spanishLocale = NSLocale(localeIdentifier: "es_ES")


	//MARK: Parse

	func test_Parse_ShouldExtractValues() {
		let xsd =
			"<root available-locales=\"en_US\" default-locale=\"en_US\"> " +
			"<dynamic-element dataType=\"document-library\" " +
				"indexType=\"keyword\" " +
				"name=\"A_Document\" " +
				"readOnly=\"false\" " +
				"repeatable=\"true\" " +
				"required=\"false\" " +
				"showLabel=\"true\" " +
				"type=\"ddm-documentlibrary\" " +
				"width=\"\"> " +
					"<meta-data locale=\"en_US\"> " +
						"<entry name=\"label\"><![CDATA[A Document]]></entry> " +
						"<entry name=\"predefinedValue\"><![CDATA[]]></entry> " +
					"</meta-data> " +
			"</dynamic-element> </root>"

		let fields = DDLXSDParser().parse(xsd, locale: spanishLocale)

		XCTAssertTrue(fields![0] is DDLFieldDocument)
		let docField = fields![0] as! DDLFieldDocument

		XCTAssertEqual(DDLField.DataType.DDLDocument, docField.dataType)
		XCTAssertEqual(DDLField.Editor.Document, docField.editorType)
		XCTAssertNil(docField.predefinedValue)
		XCTAssertEqual("A_Document", docField.name)
		XCTAssertEqual("A Document", docField.label)
	}


	//MARK: Validate

	func test_Validate_ShouldFail_WhenRequiredValueIsNil() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		XCTAssertTrue(docField.currentValue == nil)
		XCTAssertFalse(docField.validate())
	}

	func test_Validate_ShouldFail_WhenUploadFailed() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.currentValue = UIImage(contentsOfFile: testResourcePath("default-field", ext: "png"))
		docField.uploadStatus = .Failed(NSError(domain: "", code: 0, userInfo:nil))

		XCTAssertFalse(docField.validate())
	}


	//MARK: MimeType

	func test_MimeType_ShouldReturnNil_WhenCurrentValueIsEmpty() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		XCTAssertNil(docField.mimeType)
	}

	func test_MimeType_ShouldReturnPNGImageType_WhenCurrentValueIsImage() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.currentValue = UIImage(contentsOfFile: testResourcePath("default-field", ext: "png"))

		XCTAssertEqual("image/png", docField.mimeType ?? "nil mimeType")
	}

	func test_MimeType_ShouldReturnMPEGVideoType_WhenCurrentValueIsURL() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.currentValue =
				NSURL(fileURLWithPath: "/this/is/a/path/to/video.mpg", isDirectory: false)

		XCTAssertEqual("video/mpeg", docField.mimeType ?? "nil mimeType")
	}


	//MARK: Stream

	func test_Stream_ShouldReturnNil_WhenCurrentValueIsEmpty() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		var size:Int64 = 0
		XCTAssertNil(docField.getStream(&size))
		XCTAssertEqual(Int64(0), size)
	}

	func test_Stream_ShouldReturnStream_WhenCurrentValueIsImage() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		let image = UIImage(contentsOfFile: testResourcePath("default-field", ext: "png"))
		let imageBytes = UIImagePNGRepresentation(image!)
		let imageLength = Int64(imageBytes!.length)

		docField.currentValue = image

		var size:Int64 = 0
		let stream = docField.getStream(&size)
		XCTAssertNotNil(stream)
		XCTAssertEqual(imageLength, size)
	}

	func test_Stream_ShouldReturnStream_WhenCurrentValueIsURL() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		let url = NSBundle(forClass: self.dynamicType).URLForResource("default-field",
				withExtension: "png")
		let attributes =
				try? NSFileManager.defaultManager().attributesOfItemAtPath(url!.path!)
		let imageLength = attributes![NSFileSize] as! NSNumber

		docField.currentValue = url

		var size:Int64 = 0
		let stream = docField.getStream(&size)
		XCTAssertNotNil(stream)
		XCTAssertEqual(imageLength.longLongValue, size)
	}


	//MARK: currentValueAsLabel

	func test_CurrentValueAsLabel_ShouldReturnNil_WhenCurrentValueIsNil() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		XCTAssertNil(docField.currentValueAsLabel)
	}

	func test_CurrentValueAsLabel_ShouldReturnImage_WhenCurrentValueIsImage() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.currentValue = UIImage(contentsOfFile: testResourcePath("default-field", ext: "png"))

		XCTAssertEqual("An image has been selected", docField.currentValueAsLabel!)
	}

	func test_CurrentValueAsLabel_ShouldReturnVideo_WhenCurrentValueIsURL() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.currentValue =
				NSURL(fileURLWithPath: "/this/is/a/path/to/video.mpg", isDirectory: false)

		XCTAssertEqual("A video has been selected", docField.currentValueAsLabel!)
	}


	//MARK: CurrentValueAsString

	func test_CurrentValueAsString_ShouldReturnNil_WhenUploadStatusIsPending() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.uploadStatus = .Pending

		XCTAssertNil(docField.currentValueAsString)
	}

	func test_CurrentValueAsString_ShouldReturnNil_WhenUploadStatusIsUploading() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.uploadStatus = .Uploading(1,10)

		XCTAssertNil(docField.currentValueAsString)
	}

	func test_CurrentValueAsString_ShouldReturnNil_WhenUploadStatusIsFailed() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		docField.uploadStatus = .Failed(nil)

		XCTAssertNil(docField.currentValueAsString)
	}

	func test_CurrentValueAsString_ShouldReturnDDLJSON_WhenUploadStatusIsUploaded() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		let json:[String:AnyObject] = [
			"groupId": 1234,
			"uuid": "abcd",
			"version": "1.0",
			"blablabla": "blebleble"]

		docField.uploadStatus = .Uploaded(json)

		let expectedResult = "{\"groupId\":1234,\"uuid\":\"abcd\",\"version\":\"1.0\"}"
		XCTAssertEqual(expectedResult, docField.currentValueAsString!)
	}


	//MARK: UploadStatus

	func test_UploadStatus_ShouldBeUploaded_WhenSetJSONTocurrentValueAsString() {
		let fields = DDLXSDParser().parse(requiredDocumentElementXSD, locale: spanishLocale)
		let docField = fields![0] as! DDLFieldDocument

		let json = "{\"groupId\":1234,\"uuid\":\"abcd\",\"version\":\"1.0\"}"

		docField.currentValueAsString = json

		switch docField.uploadStatus {
			case .Uploaded(let uploadedAttributes):
				let expectedJson:[String:AnyObject] = [
						"groupId": 1234,
						"uuid": "abcd",
						"version": "1.0"]
				for (k,v) in expectedJson {
					XCTAssertEqual("\(v)", "\(uploadedAttributes[k]!)")
				}

			default:
				XCTFail("Upload status is expected to be 'Uploaded'")
		}
	}

	private let requiredDocumentElementXSD =
		"<root available-locales=\"en_US\" default-locale=\"en_US\"> " +
			"<dynamic-element dataType=\"document-library\" " +
				"indexType=\"keyword\" " +
				"name=\"A_Document\" " +
				"readOnly=\"false\" " +
				"repeatable=\"true\" " +
				"required=\"true\" " +
				"showLabel=\"true\" " +
				"type=\"ddm-documentlibrary\" " +
				"width=\"\"> " +
					"<meta-data locale=\"en_US\"> " +
						"<entry name=\"label\"><![CDATA[A Document]]></entry> " +
						"<entry name=\"predefinedValue\"><![CDATA[]]></entry> " +
					"</meta-data> " +
			"</dynamic-element> </root>"

}
