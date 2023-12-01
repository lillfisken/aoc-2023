CREATE OR REPLACE FUNCTION REPLACE_FIRST_AND_LAST_NUMERICTEXT_WITH_NUMRICVALUE(str TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS
$$
DECLARE
    first TEXT;
    last TEXT;
    result TEXT;
BEGIN
    SELECT 
        REPLACE(str,txt,nbr) 
    INTO first
    FROM (
        SELECT txt,nbr FROM (
            SELECT POSITION('one' in str) as pos, 'one' as txt, '1' as nbr
            UNION
            SELECT POSITION('two' in str) as pos, 'two' as txt, '2' as nbr
            UNION
            SELECT POSITION('three' in str) as pos, 'three' as txt, '3' as nbr
            UNION
            SELECT POSITION('four' in str) as pos, 'four' as txt, '4' as nbr
            UNION
            SELECT POSITION('five' in str) as pos, 'five' as txt, '5' as nbr
            UNION
            SELECT POSITION('six' in str) as pos, 'six' as txt, '6' as nbr
            UNION
            SELECT POSITION('seven' in str) as pos, 'seven' as txt, '7' as nbr
            UNION
            SELECT POSITION('eight' in str) as pos, 'eight' as txt, '8' as nbr
            UNION
            SELECT POSITION('nine' in str) as pos, 'nine' as txt, '9' as nbr
            UNION
            SELECT '99' as pos, '' as txt, '' as nbr
        )
	WHERE pos > 0
	order by pos asc
	limit 1
	);
    SELECT 
        REVERSE(REPLACE(REVERSE(str),txt,nbr) )
    INTO last
    FROM (
        SELECT txt,nbr FROM (
            SELECT POSITION(REVERSE('one') in REVERSE(str)) as pos,REVERSE('one') as txt,REVERSE('1') as nbr
            UNION
            SELECT POSITION(REVERSE('two') in REVERSE(str)) as pos,REVERSE('two') as txt,REVERSE('2') as nbr
            UNION
            SELECT POSITION(REVERSE('three') in REVERSE(str)) as pos,REVERSE('three') as txt,REVERSE('3') as nbr
            UNION
            SELECT POSITION(REVERSE('four') in REVERSE(str)) as pos,REVERSE('four') as txt,REVERSE('4') as nbr
            UNION
            SELECT POSITION(REVERSE('five') in REVERSE(str)) as pos,REVERSE('five') as txt,REVERSE('5') as nbr
            UNION
            SELECT POSITION(REVERSE('six') in REVERSE(str)) as pos,REVERSE('six') as txt,REVERSE('6') as nbr
            UNION
            SELECT POSITION(REVERSE('seven') in REVERSE(str)) as pos,REVERSE('seven') as txt,REVERSE('7') as nbr
            UNION
            SELECT POSITION(REVERSE('eight') in REVERSE(str)) as pos,REVERSE('eight') as txt,REVERSE('8') as nbr
            UNION
            SELECT POSITION(REVERSE('nine') in REVERSE(str)) as pos,REVERSE('nine') as txt,REVERSE('9') as nbr
            UNION
            SELECT '99' as pos, '' as txt, '' as nbr
        )
	WHERE pos > 0
	order by pos asc
	limit 1
	);
    SELECT CONCAT(first,last)
    INTO result;
    RETURN result;
END;
$$;

SELECT SUM(CONCAT(substring(REPLACE_FIRST_AND_LAST_NUMERICTEXT_WITH_NUMRICVALUE(calc_row) FROM '[0-9]'),
substring(reverse(REPLACE_FIRST_AND_LAST_NUMERICTEXT_WITH_NUMRICVALUE(calc_row)) FROM '[0-9]'))::bigint )
	FROM public.y2023d1t1;

