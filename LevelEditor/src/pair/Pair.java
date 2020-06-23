package pair;

import java.util.Map;

public class Pair<A, B> implements Map.Entry<A, B> {

    private final A key;
    private B value;

    public Pair(A key, B value) {
        this.key = key;
        this.value = value;
    }

    @Override
    public A getKey() {
        return key;
    }

    @Override
    public B getValue() {
        return value;
    }

    @Override
    public B setValue(B value) {
        this.value = value;
        return this.value;
    }

}
