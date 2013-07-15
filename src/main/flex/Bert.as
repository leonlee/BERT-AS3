package {
import flash.utils.getQualifiedClassName;

public class Bert {
    public static const BERT_START:String = String.fromCharCode(131);
    public static const SMALL_ATOM:String = String.fromCharCode(115);
    public static const ATOM:String = String.fromCharCode(100);
    public static const BINARY:String = String.fromCharCode(109);
    public static const SMALL_INTEGER:String = String.fromCharCode(97);
    public static const INTEGER:String = String.fromCharCode(98);
    public static const SMALL_BIG:String = String.fromCharCode(110);
    public static const LARGE_BIG:String = String.fromCharCode(111);
    public static const FLOAT:String = String.fromCharCode(99);
    public static const STRING:String = String.fromCharCode(107);
    public static const LIST:String = String.fromCharCode(108);
    public static const SMALL_TUPLE:String = String.fromCharCode(104);
    public static const LARGE_TUPLE:String = String.fromCharCode(105);
    public static const NIL:String = String.fromCharCode(106);
    public static const ZERO:String = String.fromCharCode(0);


    //static

    public static function binaryToList(binary:String):Array {
        var ret:Array = [];
        for (var i:Number = 0; i < binary.length; i++)
            ret.push(binary.charCodeAt(i));
        return ret;
    }

    public static function bytesToString(arr:Array):String {
        var s:String = "";
        for (var i:int = 0; i < arr.length; i++) {
            s += String.fromCharCode(arr[i]);
        }
        return s;
    }

    public static function bytesToList(s:String):Array {
        var ret:Array = [];
        for (var i:int = 0; i < s.length; i++)
            ret.push(s.charCodeAt(i));
        return ret;
    }

    public static function ppTerm(obj:Object):String {
        return obj.toString();
    }

    // interface

    public function encode(obj:Object):String {
        return BERT_START + encodeInner(obj);
    }

    //TODO: finish decoding
    public function decode(s:String):String {
        if (s.charAt(0) !== BERT_START) {
            throw new Error("Not a valid BERT.");
        }
        var obj = this.decodeInner(s.substring(1));
        if (obj.rest !== "") {
            throw new Error("Invalid BERT.");
        }
        return obj.value;
        return ""
    }

    // encoding

    protected function encodeInner(obj:Object):String {
//            if (obj == undefined) throw new Error("Cannot encode undefined values.")

        if (obj == null) {
            return encodeBertAtom(new BertAtom("null"));
        }

        if (obj is int || obj is Number) {
            return encodeNumber(Number(obj));
        }

        var func = 'encode' + getQualifiedClassName(obj);
        return this[func](obj);

    }


    protected function encodeString(Obj:String) {
        return STRING + intToBytes(Obj.length, 2) + Obj;
    };

    protected function encodeBoolean(bool:Boolean):String {
        if (bool) {
            return encodeInner(new BertAtom("true"));
        } else {
            return encodeInner(new BertAtom("false"));
        }
    }

    protected function encodeNumber(Obj:Number):String {
        var isInteger:Boolean = (Obj % 1 === 0);

        // Handle floats...
        if (!isInteger) {
            return encodeFloat(Obj);
        }

        // Small int...
        if (isInteger && Obj >= 0 && Obj < 256) {
            return SMALL_INTEGER + intToBytes(Obj, 1);
        }

        // 4 byte int...
        if (isInteger && Obj >= -134217728 && Obj <= 134217727) {
            return INTEGER + intToBytes(Obj, 4);
        }

        // Bignum...
        var s:String = bignumToBytes(Obj);
        if (s.length < 256) {
            return SMALL_BIG + intToBytes(s.length - 1, 1) + s;
        } else {
            return LARGE_BIG + intToBytes(s.length - 1, 4) + s;
        }
    };

    protected function encodeFloat(num:Number):String {
        trace(num.toExponential(20));
        var s:String = num.toExponential(20);
        if (s.indexOf("e+") < 0) {
            s += "e+000"
        }
        while (s.length < 31) {
            s += ZERO;
        }
        return FLOAT + s;
    };


    protected function encodeBertTuple(tuple:BertTuple):String {
        var s:String = "";
        if (tuple.length < 256) {
            s += SMALL_TUPLE + this.intToBytes(tuple.length, 1);
        } else {
            s += LARGE_TUPLE + this.intToBytes(tuple.length, 4);
        }
        for (var i:int = 0; i < tuple.length; i++) {
            s += this.encodeInner(tuple.value[i]);
        }
        return s;
    }


    protected function encodeBertAtom(atom:BertAtom):String {
        return ATOM + intToBytes(atom.value.length, 2) + atom.value;
    }

    protected function encodeBertBinary(binary:BertBinary):String {
        return BINARY + intToBytes(binary.value.toString().length, 4) + binary.value;
    }

    protected function encodeArray(array:Array):String {
        if (array.length == 0) return NIL;
        var s:String = LIST + this.intToBytes(array.length, 4);
        for (var i:int = 0; i < array.length; i++) {
            s += this.encodeInner(array[i]);
        }
        s += NIL;
        return s;
    }

    protected function encodeObject(object:Object):String {
        var arr = [];
        for (var key in object) {
            if (object.hasOwnProperty(key)) {
                arr.push(new BertTuple([new BertAtom(key), object[key]]));
            }
        }
        return this.encodeArray(arr);
    }

    protected function bignumToBytes(Int:Number):String {
        var s:String = "";
        if (Int < 0) {
            Int *= -1;
            s += String.fromCharCode(1);
        } else {
            s += String.fromCharCode(0);
        }

        while (Int !== 0) {
            var rem = Int % 256;
            s += String.fromCharCode(rem);
            Int = Math.floor(Int / 256);
        }

        return s;
    };

    protected function intToBytes(Int:int, Length:int):String {
        var isNegative:Boolean = (Int < 0);
        var s:String = "";
        if (isNegative) {
            Int = -Int - 1;
        }
        var OriginalInt:int = Int;
        for (var i:int = 0; i < Length; i++) {
            var Rem = Int % 256;
            if (isNegative) {
                Rem = 255 - Rem;
            }
            s = String.fromCharCode(Rem) + s;
            Int = Math.floor(Int / 256);
        }
        if (Int > 0) {
            throw ("Argument out of range: " + OriginalInt);
        }
        return s;
    };

    //decoding

    protected function decodeInner(s:String) {
        var Type = s.charAt(0);
        s = s.substring(1);
        switch (Type) {
            case SMALL_ATOM:
                return this.decodeAtom(s, 1);
            case ATOM:
                return this.decodeAtom(s, 2);
            case BINARY:
                return this.decodeBinary(s);
            case SMALL_INTEGER:
                return this.decodeInteger(s, 1);
            case INTEGER:
                return this.decodeInteger(s, 4);
            case SMALL_BIG:
                return this.decodeBig(s, 1);
            case LARGE_BIG:
                return this.decodeBig(s, 4);
            case FLOAT:
                return this.decodeFloat(s);
            case STRING:
                return this.decodeString(s);
            case LIST:
                return this.decodeList(s);
            case SMALL_TUPLE:
                return this.decodeTuple(s, 1);
            case LARGE_TUPLE:
                return this.decodeTuple(s, 4);
            case NIL:
                return this.decodeNil(s);
            default:
                throw new Error("Unexpected BERT type: " + s.charCodeAt(0));
        }
    };

    //TODO:fix booleans
    protected function decodeAtom(s:String, count:Number):Object {
        var size:Number = bytesToInt(s, count);
        s = s.substring(count);
        var value:String = s.substring(0, size);
        var res:Object;
        if (value == "true") {
            res = true;
        }
        else if (value === "false") {
            res = false;
        }
        else {
            res = value
        }
        return {
            value: new BertAtom(res),
            rest: s.substring(size)
        };
    }

    protected function decodeBinary(s:String):Object {
        var size:Number = bytesToInt(s, 4);
        s = s.substring(4);
        return {
            value: new BertBinary(s.substring(0, size)),
            rest: s.substring(size)
        };
    }

    protected function decodeInteger(s:String, count):Object {
        var value = this.bytesToInt(s, count);
        s = s.substring(count);
        return {
            value: value,
            rest: s
        };
    }

    protected function decodeBig(s:String, count):Object {
        var size = bytesToInt(s, count);
        s = s.substring(count);
        var value = this.bytesToBigNum(s, size);
        return {
            value: value,
            rest: s.substring(size + 1)
        };
    }

    protected function decodeFloat(s:String):Object {
        var size:Number = 31;
        return {
            value: parseFloat(s.substring(0, size)),
            rest: s.substring(size)
        };
    }

    protected function decodeString(s:String):Object {
        var size = this.bytesToInt(s, 2);
        s = s.substring(2);
        return {
            value: s.substring(0, size),
            rest: s.substring(size)
        };
    }

    protected function decodeList(s:String):Object {
        var size = this.bytesToInt(s, 4);
        s = s.substring(4);
        var arr:Array = [];
        for (var i:int = 0; i < size; i++) {
            var el = this.decodeInner(s);
            arr.push(el.value);
            s = el.rest;
        }
        var lastChar = s.charAt(0);
        if (lastChar != NIL) {
            throw new Error("List does not end with NIL!");
        }
        s = s.substring(1);
        return {
            value: arr,
            rest: s
        };
    }

    protected function decodeTuple(s:String, count):Object {
        var size = this.bytesToInt(s, count);
        s = s.substring(count);
        var arr:Array = [];
        for (var i:int = 0; i < size; i++) {
            var el = this.decodeInner(s);
            arr.push(el.value);
            s = el.rest;
        }
        return {
            value: new BertTuple(arr),
            rest: s
        };
    }

    protected function decodeNil(s:String):Object {
        return {
            value: [],
            rest: s
        }
    }

    protected function bytesToInt(s:String, length:Number):Number {
        var num:Number = 0;
        var isNegative:Boolean = (s.charCodeAt(0) > 128);
        for (var i:int = 0; i < length; i++) {
            var n:Number = s.charCodeAt(i);
            if (isNegative) {
                n = 255 - n;
            }
            if (num == 0) {
                num = n;
            }
            else {
                num = num * 256 + n;
            }
        }
        if (isNegative) {
            num = -num - 1;
        }
        return num;
    }

    protected function bytesToBigNum(s:String, length:Number):Object {
        var num:Number = 0;
        var isNegative:Boolean = (s.charCodeAt(0) == 1);
        s = s.substring(1);
        for (var i:int = length - 1; i >= 0; i--) {
            var n:Number = s.charCodeAt(i);
            if (num == 0) {
                num = n;
            }
            else {
                num = num * 256 + n;
            }
        }
        if (isNegative) {
            return -num;
        }
        return num;
    }


}
}