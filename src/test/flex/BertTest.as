/**
 * User: Anton
 */
package {
import org.flexunit.asserts.assertEquals;
import org.hamcrest.*;
import org.hamcrest.collection.array;

public class BertTest {
    public function BertTest() {
    }

    [Test]
    public function shouldEncodeAtom():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(new BertAtom(("hello")))), array(131, 100, 0, 5, 104, 101, 108, 108, 111));
    }

    [Test]
    public function shouldEncodeBinary():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(new BertBinary(("hello")))), array(131, 109, 0, 0, 0, 5, 104, 101, 108, 108, 111));
    }

    [Test]
    public function shouldEncodeBoolean():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(true)), array(131, 100, 0, 4, 116, 114, 117, 101));
    }

    [Test]
    public function shouldEncodeInts():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(0)), array(131, 97, 0));
        assertThat(Bert.binaryToList(bert.encode(-1)), array(131, 98, 255, 255, 255, 255));
        assertThat(Bert.binaryToList(bert.encode(42)), array(131, 97, 42));
        assertThat(Bert.binaryToList(bert.encode(5000)), array(131, 98, 0, 0, 19, 136));
        assertThat(Bert.binaryToList(bert.encode(-5000)), array(131, 98, 255, 255, 236, 120));
        assertThat(Bert.binaryToList(bert.encode(987654321)), array(131, 110, 4, 0, 177, 104, 222, 58));
        assertThat(Bert.binaryToList(bert.encode(-987654321)), array(131, 110, 4, 1, 177, 104, 222, 58));
    }

    [Test]
    public function shouldEncodeNull():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(null)), array(131, 100, 0, 4, 110, 117, 108, 108));
    }


    [Test]
    public function shouldEncodeFloats():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(2.5)), array(131, 99, 50, 46, 53, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 101, 43, 48, 48, 48, 0, 0, 0, 0));
        assertThat(Bert.binaryToList(bert.encode(3.14159)), array(131, 99, 51, 46, 49, 52, 49, 53, 56, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 56, 56, 50, 54, 49, 101, 43, 48, 48, 48, 0, 0, 0, 0));
        assertThat(Bert.binaryToList(bert.encode(-3.14159)), array(131, 99, 45, 51, 46, 49, 52, 49, 53, 56, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 56, 56, 50, 54, 49, 101, 43, 48, 48, 48, 0, 0, 0));
    }


    [Test]
    public function shouldEncodeArray():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(["1", "2", "3"])), array(131, 108, 0, 0, 0, 3, 107, 0, 1, 49, 107, 0, 1, 50, 107, 0, 1, 51, 106));
    }

    [Test]
    public function shouldEncodeAssocArray():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode({a: 1, b: 2, c: 3})), array(131, 108, 0, 0, 0, 3, 104, 2, 100, 0, 1, 97, 97, 1, 104, 2, 100, 0, 1, 98, 97, 2, 104, 2, 100, 0, 1, 99, 97, 3, 106));
    }

    [Test]
    public function shouldEncodeTuple():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode(new BertTuple(["Hello", 1]))), array(131, 104, 2, 107, 0, 5, 72, 101, 108, 108, 111, 97, 1));
    }

    [Test]
    public function shouldEncodeEmptyList():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode([])), array(131, 106));
    }

    [Test]
    public function shouldEncodeComplex():void {
        var bert:Bert = new Bert();
        assertThat(Bert.binaryToList(bert.encode({a: new BertTuple([1, 2, 3]), b: [400, 5, 6]})),
                array(131, 108, 0, 0, 0, 2, 104, 2, 100, 0, 1, 97, 104, 3, 97, 1, 97, 2, 97, 3, 104, 2, 100, 0, 1, 98, 108, 0, 0, 0, 3, 98, 0, 0, 1, 144, 97, 5, 97, 6, 106, 106));
    }

    //decode

    [Test]
    public function shouldDecodeComplex():void {
        var bert:Bert = new Bert();
        var term:Object = bert.decode(Bert.bytesToString([131, 108, 0, 0, 0, 4, 104, 2, 100, 0, 4, 97, 116, 111, 109, 100, 0, 6, 109, 121, 65, 116, 111, 109, 104, 2, 100, 0, 6, 98, 105, 110, 97, 114, 121, 109, 0, 0, 0, 9, 77, 121, 32, 66, 105, 110, 97, 114, 121, 104, 2, 100, 0, 4, 98, 111, 111, 108, 100, 0, 4, 116, 114, 117, 101, 104, 2, 100, 0, 6, 115, 116, 114, 105, 110, 103, 107, 0, 11, 72, 101, 108, 108, 111, 32, 116, 104, 101, 114, 101, 106]));
        assertEquals(Bert.ppTerm(term), '{atom, myAtom},{binary, <<"My Binary">>},{bool, true},{string, Hello there}');
    }

    [Test]
    public function shouldDecodeEmptyList():void {
        var bert:Bert = new Bert();
        var term:Object = bert.decode(Bert.bytesToString([131, 106]));
        assertEquals(Bert.ppTerm(term), []);
    }

    [Test]
    public function shouldDecodeNegativeInts():void {
        var bert:Bert = new Bert();
        var term:Object = bert.decode(Bert.bytesToString([131,98,255,255,255,255]));
        assertEquals(Bert.ppTerm(term), -1);
    }

    [Test]
    public function shouldDecodeInts():void {
        var bert:Bert = new Bert();
        var term:Object = bert.decode(Bert.bytesToString([131, 108, 0, 0, 0, 5, 104, 2, 100, 0, 13, 115, 109, 97, 108, 108, 95, 105, 110, 116, 101, 103, 101, 114, 97, 42, 104, 2, 100, 0, 8, 105, 110, 116, 101, 103, 101, 114, 49, 98, 0, 0, 19, 136, 104, 2, 100, 0, 8, 105, 110, 116, 101, 103, 101, 114, 50, 98, 255, 255, 236, 120, 104, 2, 100, 0, 8, 98, 105, 103, 95, 105, 110, 116, 49, 110, 4, 0, 177, 104, 222, 58, 104, 2, 100, 0, 8, 98, 105, 103, 95, 105, 110, 116, 50, 110, 4, 1, 177, 104, 222, 58, 106]));
        assertEquals(Bert.ppTerm(term), '{small_integer, 42},{integer1, 5000},{integer2, -5000},{big_int1, 987654321},{big_int2, -987654321}');
    }

    [Test]
    public function shouldDecodeFloats():void {
        var bert:Bert = new Bert();
        var term:Object = bert.decode(Bert.bytesToString([131, 99, 45, 51, 46, 49, 52, 49, 53, 56, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 56, 56, 50, 54, 50, 101, 43, 48, 48, 0, 0, 0, 0]));
        assertEquals(Bert.ppTerm(term), -3.14159);
    }

}
}
