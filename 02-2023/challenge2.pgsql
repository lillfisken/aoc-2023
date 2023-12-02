CREATE OR REPLACE FUNCTION GET_CUBE_POWER_Y2023D2T1(gameNo INTEGER )
RETURNS BIGINT
LANGUAGE plpgsql
AS
$$
DECLARE
    power BIGINT;
    max_red INTEGER;
    max_green INTEGER;
    max_blue INTEGER;
BEGIN
    SELECT red
    INTO max_red
    FROM public.y2023d2t1
    WHERE game = gameNo
    ORDER BY red DESC
    LIMIT 1
    ;
    SELECT green
    INTO max_green
    FROM public.y2023d2t1
    WHERE game = gameNo
    ORDER BY green DESC
    LIMIT 1
    ;
    SELECT blue
    INTO max_blue
    FROM public.y2023d2t1
    WHERE game = gameNo
    ORDER BY blue DESC
    LIMIT 1
    ;
    SELECT max_red * max_green * max_blue
    INTO power;
    RETURN power;
END;
$$;

SELECT SUM(GET_CUBE_POWER_Y2023D2T1(game))
FROM (
	SELECT DISTINCT game 
	FROM public.y2023d2t1
);