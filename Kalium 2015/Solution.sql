CREATE TEMP TABLE IF NOT EXISTS [segmentsCopy] (
      l integer NOT null,
      r integer NOT null,
      CHECK(l <= r),
      UNIQUE(l, r)
);
DELETE FROM [segmentsCopy];
INSERT INTO [segmentsCopy] SELECT * FROM [segments];

CREATE TEMP TABLE IF NOT EXISTS [segmentsClear] (
      l integer NOT null,
      r integer NOT null,
      CHECK(l <= r),
      UNIQUE(l, r)
);
DELETE FROM [segmentsClear];
INSERT INTO [segmentsClear]
	SELECT * FROM segments
	except
	SELECT DISTINCT [segments].l AS l, [segments].r AS r 
	FROM [segments] CROSS JOIN [segmentsCopy]
	WHERE ([segments].l >  [segmentsCopy].l AND [segments].r <= [segmentsCopy].r) || 
		  ([segments].l >= [segmentsCopy].l AND [segments].r <  [segmentsCopy].r) || 
		  ([segments].l >  [segmentsCopy].l AND [segments].r <  [segmentsCopy].r);

CREATE TEMP TABLE IF NOT EXISTS [segmetsClearCopy] (
      l integer NOT null,
      r integer NOT null,
      CHECK(l <= r),
      UNIQUE(l, r)
);
DELETE FROM [segmetsClearCopy];
INSERT INTO [segmetsClearCopy] SELECT * FROM [segmentsClear];

CREATE TEMP TABLE IF NOT EXISTS [temp] (
      lm integer NOT null,
      rm integer NOT null,
      lr integer NOT null,
      rr integer NOT null
);
DELETE FROM [temp];
INSERT INTO [temp] 
	SELECT [segmentsClear].l AS lm, [segmentsClear].r AS rm, MIN([segmetsClearCopy].l) AS lr, [segmetsClearCopy].r AS rr
	FROM [segmentsClear] CROSS JOIN [segmetsClearCopy]
	WHERE [segmentsClear].l <  [segmetsClearCopy].l AND 
	              [segmentsClear].r >= [segmetsClearCopy].l AND 
		      [segmentsClear].r <  [segmetsClearCopy].r
	GROUP BY lm, rm;

SELECT IFNULL(SUM(sum), 0) 
FROM
(
	SELECT SUM(CASE WHEN l is NULL THEN (rr - lm) ELSE rr - MAX(rm, lr) END) as sum
	FROM [temp]
	LEFT JOIN  (SELECT distinct lr as l, rr as r FROM temp)  ON l = lm AND r = rm
	UNION
	SELECT SUM(sum) as sum
	FROM
	(
		SELECT [segmentsClear].r - [segmentsClear].l as sum
		FROM [segmentsClear] CROSS JOIN [segmetsClearCopy]
		WHERE ([segmentsClear].l <= [segmetsClearCopy].l AND [segmentsClear].r >= [segmetsClearCopy].l) || 
	    	  ([segmentsClear].l <= [segmetsClearCopy].r AND [segmentsClear].r >=  [segmetsClearCopy].r)
		GROUP BY [segmentsClear].l, [segmentsClear].r
		HAVING COUNT(*) = 1
	)
);