import TempoKit
import Foundation
import FileKit

public protocol CredentialService {
    func save(config: JIRAConfig, completion: @escaping () -> Void)
    func load(completion: @escaping (JIRAConfig) -> Void)
}

public protocol UsesCredentialService {
    var credentialService: CredentialService { get }
}

public class MixinCredentialService: CredentialService {
    private let fileKit: FileKit
    private let appFolderName: String = "nl.eelcokoelewijn.tempo"
    private let configFileName: String = ".config"

    public init() {
        fileKit = FileKit()
    }
    
    public func save(config: JIRAConfig, completion: @escaping () -> Void) {
        let data = try! JSONSerialization.data(withJSONObject: config.toJSON(), options: [])
        fileKit.save(file: self.config(data), queue: DispatchQueue.global()) { _ in
                completion()
        }
    }
    
    public func load(completion: @escaping (JIRAConfig) -> Void) {
        fileKit.load(file: config()) { [unowned self] result in
            if case let .success(file) = result,
                let data = file.data,
                let config = self.make(data: data) {
                 completion(config)
            } else {
                print("No config")
                exit(6)
            }
        }
    }
    
    private func make(data: Data) -> JIRAConfig? {
        guard let r = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
        return JIRAConfig(json: r)
    }
    
    private func config(_ data: Data? = nil) -> File {
        let folder = URL(string: self.appFolderName, relativeTo: FileKit.cachesFolder().path)!	
        let file = File(name: self.configFileName, folder: Folder(path: folder), data: data)
        return file
    }
}
	
