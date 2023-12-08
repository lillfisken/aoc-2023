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
CREATE OR REPLACE FUNCTION public.get_stars_y2023d3t2(
	in_src text)
    RETURNS SETOF integer 
    LANGUAGE 'plpgsql'
AS $$
DECLARE
	ix INTEGER := 1;
	ch CHAR;
BEGIN
	FOREACH ch IN ARRAY regexp_split_to_array(in_src, '')
	LOOP
		IF ch = '*' THEN
			RETURN NEXT ix;
		END IF;
		ix := ix+1;
	END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION GET_COGS_Y2023D3T2(in_row_no INTEGER, in_star_pos INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
AS
$$
DECLARE
	ix_rec INTEGER := 0;
    rec record;
	tmp TEXT;
	result NUMERIC := 1;
BEGIN
	FOR rec IN
		SELECT 
		row_no,
		substr(modified_input,in_star_pos-1,3) as maybe_star,
		substr(modified_input,in_star_pos-4,9) as src_star
		FROM public.y2023d3t2
		WHERE row_no >= in_row_no-1
		AND row_no <= in_row_no+1
		AND substr(modified_input,in_star_pos-1,3) ~ '[\d]' = true
	LOOP
        -- \d = Digit?
        -- \D = Non-Digit?
        -- i.e. '.99'
		IF rec.maybe_star ~ '\D\d\d' THEN
			tmp := unnest(regexp_matches(substr(rec.src_star,4,5),'(\D[0-9]+\D)'));
			IF tmp IS NOT NULL THEN
				result := result * CAST(substr(tmp,2,length(tmp)-2) AS BIGINT);
		        ix_rec := ix_rec +1;
			END IF;
		END IF;
        --- i.e. 'x.9'
		IF substr(rec.maybe_star,2,2) ~ '\D\d' THEN
			tmp := unnest(regexp_matches(substr(rec.src_star,5,5),'(\D[0-9]+\D)'));
			IF tmp IS NOT NULL THEN
				result := result * CAST(substr(tmp,2,length(tmp)-2) AS BIGINT);
		        ix_rec := ix_rec +1;
			END IF;
		END IF;
        --- i.e. '99.'
		IF rec.maybe_star ~ '\d\d\D' THEN
			tmp := unnest(regexp_matches(substr(rec.src_star,2,5),'(\D[0-9]+\D)'));
			IF tmp IS NOT NULL THEN
				result := result * CAST(substr(tmp,2,length(tmp)-2) AS BIGINT);
		        ix_rec := ix_rec +1;
			END IF;
		END IF;
        --- i.e. '9.x'
		IF substr(rec.maybe_star,1,2) ~ '\d\D' THEN
			tmp := unnest(regexp_matches(substr(rec.src_star,1,5),'(\D[0-9]+\D)'));
			IF tmp IS NOT NULL THEN
				result := result * CAST(substr(tmp,2,length(tmp)-2) AS BIGINT);
		        ix_rec := ix_rec +1;
			END IF;
		END IF;
        --- 
		IF rec.maybe_star ~ '\d\d\d' THEN
            result := result * CAST(rec.maybe_star AS BIGINT);
		    ix_rec := ix_rec +1;
		END IF;
        --- 
		IF rec.maybe_star ~ '\D\d\D' THEN
            result := result * CAST(substr(rec.maybe_star,2,1) AS BIGINT);
		    ix_rec := ix_rec +1;
		END IF;
	END LOOP;
	IF ix_rec > 1 THEN
		RETURN result;
	ELSE
		RETURN 0;
	END IF;
END;
$$;

--------------------------------------------------------------------------
-- Run query
--------------------------------------------------------------------------
SELECT SUM(GET_COGS_Y2023D3T2(row_no,star_pos))
FROM (
	SELECT row_no, GET_STARS_Y2023D3T2(modified_input) as star_pos
	FROM public.y2023d3t2
	)