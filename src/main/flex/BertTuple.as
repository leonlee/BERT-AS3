package {
public class BertTuple {

    public var value:Array;

    public function BertTuple(args) {
        this.value = [];
        for (var i:int = 0; i < args.length; i++) {
            this.value[i] = args[i]
        }
    }

    public function get length():Number {
        return value.length;
    }

    public function toString():String {
        var s:String = "";
        for (var i:int = 0; i < this.length; i++) {
            if (s != "") {
                s += ", ";
            }
            s += this.value[i].toString();
        }

        return "{" + s + "}";
    }
}
}