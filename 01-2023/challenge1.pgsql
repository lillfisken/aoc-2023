SELECT SUM(CONCAT(substring(calc_row FROM '[0-9]'),
substring(reverse(calc_row) FROM '[0-9]'))::bigint )
	FROM public.y2023d1t1;
