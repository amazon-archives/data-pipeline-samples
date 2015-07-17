set kinesis.checkpoint.iteration.no=${iterationNo};


--The following query will create OS-ERROR_COUNT result under dynamic partition for iteration no 0
INSERT OVERWRITE TABLE apachelog_s3 partition (iteration_no=${hiveconf:kinesis.checkpoint.iteration.no}) SELECT OS, COUNT(*) AS COUNT
FROM (
   SELECT regexp_extract(agent,'.*(Windows|Linux).*',1) AS OS
   FROM apachelog WHERE STATUS=404
) X
WHERE OS IN ('Windows','Linux')
GROUP BY OS;
