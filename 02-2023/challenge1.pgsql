SELECT SUM(DISTINCT game)
FROM public.y2023d2t1
WHERE game not in (
	SELECT DISTINCT game
	FROM public.y2023d2t1
	WHERE red > 12
	OR green > 13
	OR blue > 14
)
;