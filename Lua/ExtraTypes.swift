import Foundation

extension NSPoint: Value {
    
    public func push(vm: VirtualMachine) {
        let t = vm.createTable()
        t["x"] = Double(self.x)
        t["y"] = Double(self.y)
        t.push(vm)
    }
    
    public func kind() -> Kind { return .Table }
    
    private static let typeName: String = "point (table with numeric keys x,y)"
    public static func arg(vm: VirtualMachine, value: Value) -> String? {
        if value.kind() != .Table { return typeName }
        if let result = Table.arg(vm, value: value) { return result }
        let t = value as! Table
        if !(t["x"] is Number) || !(t["y"] is Number) { return typeName }
        return nil
    }
    
}

extension NSSize: Value {
    
    public func push(vm: VirtualMachine) {
        let t = vm.createTable()
        t["w"] = Double(self.width)
        t["h"] = Double(self.height)
        t.push(vm)
    }
    
    public func kind() -> Kind { return .Table }
    
    private static let typeName: String = "size (table with numeric keys w,h)"
    public static func arg(vm: VirtualMachine, value: Value) -> String? {
        if value.kind() != .Table { return typeName }
        if let result = Table.arg(vm, value: value) { return result }
        let t = value as! Table
        if !(t["w"] is Number) || !(t["h"] is Number) { return typeName }
        return nil
    }
    
}

extension Table {
    
    public func toPoint() -> NSPoint? {
        let x = self["x"] as? Number
        let y = self["y"] as? Number
        if x == nil || y == nil { return nil }
        return NSPoint(x: x!.toDouble(), y: y!.toDouble())
    }
    
    public func toSize() -> NSSize? {
        let w = self["w"] as? Number
        let h = self["h"] as? Number
        if w == nil || h == nil { return nil }
        return NSSize(width: w!.toDouble(), height: h!.toDouble())
    }
    
}

extension Arguments {
    
    public var point: NSPoint { return (values.removeAtIndex(0) as! Table).toPoint()! }
    public var size:  NSSize  { return (values.removeAtIndex(0) as! Table).toSize()!  }
    
}
