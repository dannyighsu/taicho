//
//  DataUtils.swift
//  Taicho
//
//  Created by Daniel Hsu on 11/2/22.
//

import Foundation

class DataUtils {

    static func getDocumentsDirectory() -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let filePathString = paths[safe: 0] else {
            return nil
        }
        return URL(fileURLWithPath: filePathString)
    }

    /**
     Saves the given string to a file and returns the location of the file.
     */
    static func saveStringToFile(_ string: String, fileName: String) -> URL? {
        let data = Data()
        guard let filePath = getDocumentsDirectory()?.appendingPathComponent(fileName) else {
            Log.assert("Failed to get file directory.")
            return nil
        }

        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            Log.error("Error writing the file: \(error.localizedDescription)")
        }
        return nil

    }

}
