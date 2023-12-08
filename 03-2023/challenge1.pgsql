--------------------------------------------------------------------------
-- Insert modified data into work table
--------------------------------------------------------------------------
DELETE FROM public.y2023d3t2;

INSERT INTO public.y2023d3t2(row_no, modified_input)	
SELECT ROW_NUMBER () OVER () as row_no,  input_raw
    FROM (
        SELECT REPEAT('.',200) as input_raw
        UNION ALL
        SELECT '.' || input_raw || '.' FROM public.y2023d3t1
        UNION ALL
        SELECT REPEAT('.',200) as input_raw
    );
--------------------------------------------------------------------------
-- Create functions
--------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GET_VALID_NUMBER_Y2023D3T2(
    in_row_no BIGINT, in_match_no TEXT, in_startpos INTEGER, in_length INTEGER )
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
    new_no INTEGER;
    tmp_next_row TEXT;
    tmp_prev_row TEXT;
    tmp_new_no INTEGER;
BEGIN
    SELECT substr(modified_input, in_startpos, in_length)
    FROM public.y2023d3t2
    INTO tmp_next_row
    WHERE row_no = in_row_no+1
    ;
    SELECT substr(modified_input, in_startpos, in_length)
    FROM public.y2023d3t2
    INTO tmp_prev_row
    WHERE row_no = in_row_no-1
    ;

    SELECT substr(in_match_no, 2, length(in_match_no)-2)
	INTO tmp_new_no;
    SELECT
        CASE
            WHEN (tmp_prev_row ~ '[^\.^\d]' OR
                in_match_no ~ '[^\.^\d]' OR
                tmp_next_row ~ '[^\.^\d]') THEN 
                tmp_new_no   
            ELSE
                0
        END
    INTO new_no
    ;        
    RETURN new_no;
END;
$$;

CREATE OR REPLACE FUNCTION SUM_ROW(row_no INTEGER, src TEXT )
RETURNS INTEGER
LANGUAGE plpgsql
AS
$$
DECLARE
    const_re TEXT := '(\D[0-9]+\D)';
    tmp_startpos INTEGER := 1;
    tmp_count INTEGER;
    tmp_src TEXT[];
    tmp_sum INTEGER := 0;
	resultx TEXT;
BEGIN
	RAISE NOTICE 'No % (%)',row_no,src;
	SELECT COUNT(*) FROM ( SELECT unnest(regexp_matches(substr(src,tmp_startpos),const_re)) )
	INTO tmp_count;
	LOOP
		IF tmp_count > 0 THEN
			SELECT regexp_matches(substr(src,tmp_startpos),const_re) 
            INTO tmp_src; -- Find first match
			SELECT POSITION(array_to_string(tmp_src,',') IN substr(src,tmp_startpos)) + tmp_startpos -1 -- Position of first match
			INTO tmp_startpos; -- Find actual position
            SELECT tmp_sum + 
				GET_VALID_NUMBER_Y2023D3T2(
					row_no, 
					array_to_string(tmp_src, ''), 
					tmp_startpos, 
					LENGTH(ARRAY_TO_STRING(tmp_src,''))
				)
            INTO tmp_sum;
			tmp_startpos := tmp_startpos + 1; -- Move startpos one step to search next
			SELECT COUNT(*) FROM ( SELECT unnest(regexp_matches(substr(src,tmp_startpos),const_re)) )
			INTO tmp_count;	
		ELSE
			EXIT;
		END IF;
	END LOOP;
    RETURN tmp_sum;
END;
$$;
--------------------------------------------------------------------------
-- Run query
--------------------------------------------------------------------------
SELECT SUM(SUM_ROW(row_no, modified_input))
FROM public.y2023d3t2
;