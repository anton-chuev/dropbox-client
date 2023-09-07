//
//  DeleteEntryServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 07.09.2023.
//

@testable import dropbox_client
import SwiftyDropbox

final class DeleteEntryServiceMock {
    var deleteEntryGotCalledWith = (String())
    var completeClosure: ((Files.DeleteResult?, CallError<Files.DeleteError>?) -> Void)!
    
    func deleteEntrySuccess() {
        completeClosure(Files.DeleteResult.stub(), nil)
    }
        
    func deleteEntryFail(error: Error?) {
        completeClosure(nil, CallError.clientError(nil))
    }
}

extension DeleteEntryServiceMock: DeleteEntryService {
    func delete(at path: String, completion: @escaping (Files.DeleteResult?, CallError<Files.DeleteError>?) -> Void) {
        deleteEntryGotCalledWith = (path)
        completeClosure = completion
    }
}

