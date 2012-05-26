select count(*) from UP_RAW_EVENTS where AGGREGATED=1

update UP_RAW_EVENTS set AGGREGATED=0 where AGGREGATED=1;
delete from UP_EVENT_AGGR_STATUS;
delete from UP_EVENT_SESSION_GROUPS;
delete from UP_EVENT_SESSION;
delete from UP_LOGIN_EVENT_AGGREGATE__UIDS;
delete from UP_LOGIN_EVENT_AGGREGATE;
delete from UP_AGGREGATE_GROUP_MAPPING;



select LEA.AGGR_INTERVAL, LEA.LOGIN_COUNT, LEA.UNIQUE_LOGIN_COUNT, LEA.DURATION, DD.DD_DATE, TD.TD_TIME, (select count(*) from UP_LOGIN_EVENT_AGGREGATE__UIDS LEAU where LEA.ID = LEAU.LOGIN_AGGR_ID) as IDS
from UP_LOGIN_EVENT_AGGREGATE LEA
	LEFT JOIN UP_DATE_DIMENSION DD on LEA.DATE_DIMENSION_ID = DD.DATE_ID
	LEFT JOIN UP_TIME_DIMENSION TD on LEA.TIME_DIMENSION_ID = TD.TIME_ID
where LEA.AGGREGATED_GROUP_ID = (select ID from UP_AGGREGATE_GROUP_MAPPING	where GROUP_NAME='Everyone' and GROUP_SERVICE='local') and LEA.AGGR_INTERVAL in ('HOUR', 'DAY')
order by DD.DD_DATE DESC, TD.TD_TIME DESC

SELECT DD.DD_YEAR, DD.DD_MONTH, DD.DD_DAY, TD.TD_HOUR, TD.TD_MINUTE, LEA.LOGIN_COUNT, LEA.UNIQUE_LOGIN_COUNT
FROM UP_LOGIN_EVENT_AGGREGATE LEA
	LEFT JOIN UP_DATE_DIMENSION DD on LEA.DATE_DIMENSION_ID = DD.DATE_ID
	LEFT JOIN UP_TIME_DIMENSION TD on LEA.TIME_DIMENSION_ID = TD.TIME_ID
WHERE ( DD.DD_DATE >= To_date('2012/04/16', 'yyyy/mm/dd') AND DD.DD_DATE < To_date('2012/04/17', 'yyyy/mm/dd') ) AND
       LEA.AGGR_INTERVAL='FIVE_MINUTE' and LEA.AGGREGATED_GROUP_ID=791
       
       
SELECT DD.DD_YEAR, DD.DD_MONTH, DD.DD_DAY, TD.TD_HOUR, TD.TD_MINUTE, LEA.LOGIN_COUNT, LEA.UNIQUE_LOGIN_COUNT
FROM UP_LOGIN_EVENT_AGGREGATE LEA
	LEFT JOIN UP_DATE_DIMENSION DD on LEA.DATE_DIMENSION_ID = DD.DATE_ID
	LEFT JOIN UP_TIME_DIMENSION TD on LEA.TIME_DIMENSION_ID = TD.TIME_ID
WHERE ( DD.DD_DATE >= To_date('2012/04/16', 'yyyy/mm/dd') AND DD.DD_DATE < To_date('2012/04/17', 'yyyy/mm/dd') ) AND
       ( DD.DD_DATE > To_date('2012/04/16', 'yyyy/mm/dd') OR TD.TD_TIME >= To_date('1970/01/01 07:21', 'yyyy/mm/dd HH24:MI') ) AND
       ( DD.DD_DATE < To_date('2012/04/16', 'yyyy/mm/dd') OR TD.TD_TIME < To_date('1970/01/01 09:20', 'yyyy/mm/dd HH24:MI') ) AND
       LEA.AGGR_INTERVAL='FIVE_MINUTE' and LEA.AGGREGATED_GROUP_ID=791



SELECT DD.DD_YEAR, DD.DD_MONTH, DD.DD_DAY, TD.TD_HOUR, TD.TD_MINUTE
FROM   UP_DATE_DIMENSION DD, UP_TIME_DIMENSION TD 
WHERE  ( DD.DD_DATE BETWEEN To_date('2012/04/15', 'yyyy/mm/dd') AND 
                            To_date('2012/04/17', 'yyyy/mm/dd') ) AND
       ( DD.DD_DATE > To_date('2012/04/15', 'yyyy/mm/dd') OR TD.TD_TIME > To_date('1970/01/01 00:04', 'yyyy/mm/dd HH24:MI') ) AND
       ( DD.DD_DATE < To_date('2012/04/17', 'yyyy/mm/dd') OR TD.TD_TIME < To_date('1970/01/01 23:55', 'yyyy/mm/dd HH24:MI') )
ORDER  BY DD.DD_DATE, 
          TD.TD_TIME 






