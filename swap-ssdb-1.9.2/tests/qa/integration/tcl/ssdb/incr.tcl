source "./ssdb/init_ssdb.tcl"
start_server {tags {"ssdb"}} {
    test {INCR against non existing key} {
        set res {}
        r del novar
        append res [r incr novar]
        append res [r get novar]
    } {11}

    test {INCR against key created by incr itself} {
        r incr novar
    } {2}

    test {INCR against key originally set with SET} {
        r set novar 100
        r incr novar
    } {101}

    test {INCR over 32bit value} {
        r set novar 17179869184
        r incr novar
    } {17179869185}

    test {INCRBY over 32bit value with over 32bit increment} {
        r set novar 17179869184
        r incrby novar 17179869184
    } {34359738368}

    test {INCR fails against key with spaces (left)} {
        r set novar "    11"
        catch {r incr novar} err
        format $err
    } {ERR*}

    test {INCR fails against key with spaces (right)} {
        r set novar "11    "
        catch {r incr novar} err
        format $err
    } {ERR*}

    test {INCR fails against key with spaces (both)} {
        r set novar "    11    "
        catch {r incr novar} err
        format $err
    } {ERR*}

    test {INCR fails against a key holding a list} {
        r rpush mylist 1
        catch {r incr mylist} err
        r rpop mylist
        format $err
    } {WRONGTYPE*}

    test {DECRBY over 32bit value with over 32bit increment, negative res} {
        r set novar 17179869184
        r decrby novar 17179869185
    } {-1}
    r del mylist

    test {INCRBYFLOAT against non existing key} {
        r del novar
        list    [roundFloat [r incrbyfloat novar 1]] \
                [roundFloat [r get novar]] \
                [roundFloat [r incrbyfloat novar 0.25]] \
                [roundFloat [r get novar]]
    } {1 1 1.25 1.25}

    test {INCRBYFLOAT against key originally set with SET} {
        r set novar 1.5
        roundFloat [r incrbyfloat novar 1.5]
    } {3}

    test {INCRBYFLOAT over 32bit value} {
        r set novar 17179869184
        r incrbyfloat novar 1.5
    } {17179869185.5}

    test {INCRBYFLOAT over 32bit value with over 32bit increment} {
        r set novar 17179869184
        r incrbyfloat novar 17179869184
    } {34359738368}

    test {INCRBYFLOAT fails against key with spaces (left)} {
        set err {}
        r set novar "    11"
        catch {r incrbyfloat novar 1.0} err
        format $err
    } {ERR*valid*}

    test {INCRBYFLOAT fails against key with spaces (right)} {
        set err {}
        r set novar "11    "
        catch {r incrbyfloat novar 1.0} err
        format $err
    } {ERR*valid*}

    test {INCRBYFLOAT fails against key with spaces (both)} {
        set err {}
        r set novar " 11 "
        catch {r incrbyfloat novar 1.0} err
        format $err
    } {ERR*valid*}

    test {INCRBYFLOAT fails against a key holding a list} {
        r del mylist
        set err {}
        r rpush mylist 1
        catch {r incrbyfloat mylist 1.0} err
        r del mylist
        format $err
    } {WRONGTYPE*}

    test {INCRBYFLOAT does not allow NaN or Infinity} {
        r set foo 0
        set err {}
        catch {r incrbyfloat foo +inf} err
        set err
        # p.s. no way I can force NaN to test it from the API because
        # there is no way to increment / decrement by infinity nor to
        # perform divisions.
    } {ERR*would produce*}

    test {INCRBYFLOAT decrement} {
        r set foo 1
        roundFloat [r incrbyfloat foo -1.1]
    } {-0.1}
}
