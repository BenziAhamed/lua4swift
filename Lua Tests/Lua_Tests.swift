import Cocoa
import XCTest
import Lua

class Lua_Tests: XCTestCase {
    
    func testFundamentals() {
        let vm = Lua.VirtualMachine()
        let table = vm.createTable()
        table[3] = "foo"
        XCTAssert(table[3] is String)
        XCTAssertEqual(table[3] as! String, "foo")
    }
    
    func testStringX() {
        let vm = Lua.VirtualMachine()
        
        let stringxLib = vm.createTable()
        
        stringxLib["split"] = vm.createFunction([String.arg, String.arg]) { args in
            let (subject, separator) = (args.string, args.string)
            let fragments = subject.componentsSeparatedByString(separator)
            
            let results = vm.createTable()
            for (i, fragment) in fragments.enumerate() {
                results[i+1] = fragment
            }
            return .Value(results)
        }
        
        vm.globals["stringx"] = stringxLib
        
        switch vm.eval("return stringx.split('hello world', ' ')", args: []) {
        case let .Values(values):
            XCTAssertEqual(values.count, 1)
            XCTAssert(values[0] is Table)
            let array: [String] = (values[0] as! Table).asSequence()
            XCTAssertEqual(array, ["hello", "world"])
        case let .Error(e):
            XCTFail(e)
        }
    }
    
        func testCustomType() {
        
        class Note : CustomTypeInstance {
            var name = ""
            static func luaTypeName() -> String {
                return "note"
            }
        }
    
        let vm = Lua.VirtualMachine()
        
        let noteLib:CustomType<Note> = vm.createCustomType {
            type in
            type["setName"] = type.createMethod([String.arg]) {
                note, args in
                note.name = args.string
                return .Nothing
            }
            type["getName"] = type.createMethod([]) {
                note, args in
                return .Value(note.name)
            }
        }
        
        noteLib["new"] = vm.createFunction([String.arg]) {
            args in
            let note = Note()
            note.name = args.string
            let data = vm.createUserdata(note)
            return .Value(data)
        }

        // setup the note class
        vm.globals["note"] = noteLib
        
        vm.eval("myNote = note.new('a custom note')")
        XCTAssert(vm.globals["myNote"] is Userdata)
        
        // extract the note
        // and see if the name is the same
        
        let myNote:Note = (vm.globals["myNote"] as! Userdata).toCustomType()
        XCTAssert(myNote.name == "a custom note")
        
        // This is just to highlight changes in Swift
        // will get reflected in Lua as well
        // TODO: redirect output from Lua to check if both
        // are equal
        
        myNote.name = "now from XCTest"
        vm.eval("print(myNote:getName())")
        
        // further checks to change name in Lua
        // and see change reflected in the Swift object
        
        vm.eval("myNote:setName('even')")
        XCTAssert(myNote.name == "even")
        
        vm.eval("myNote:setName('odd')")
        XCTAssert(myNote.name == "odd")
        
    }

    
}
