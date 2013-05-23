-- Source
with t as (
SELECT 
    SRVR_KY
    , VSM_OS_VERS_NM
    , CASE 
          WHEN OS_VERS_END_OF_SUPP_DT is NULL THEN 
            CASE
                WHEN  VSM_OS_VERS_NM  = TGT_OS_VERS_NM THEN
                    'Green'
                ELSE
                    'Red'
            END
          WHEN MONTHS_BETWEEN(OS_VERS_END_OF_SUPP_DT, my_date.TEST_DATE) > 24 THEN
            'Green'
          WHEN MONTHS_BETWEEN(OS_VERS_END_OF_SUPP_DT, my_date.TEST_DATE) <= 24 and MONTHS_BETWEEN(OS_VERS_END_OF_SUPP_DT, my_date.TEST_DATE) > 12  THEN
            'Yellow'
          WHEN MONTHS_BETWEEN(OS_VERS_END_OF_SUPP_DT, my_date.TEST_DATE) <= 12 and MONTHS_BETWEEN(OS_VERS_END_OF_SUPP_DT, my_date.TEST_DATE) > -12  THEN
            'Red'
          WHEN MONTHS_BETWEEN(OS_VERS_END_OF_SUPP_DT, my_date.TEST_DATE) <= -12 THEN
            'Purple'
    END OS_VERS_CMPLNC_STAT_NM
    , case
        when upper(SRVR_PATCH_RQR_IND) = 'N' then
            'Green'
        else
            case
                when t.EXCPN_SRVR_NM_LIST_TX is null then
                    'Red'
                else
                    'Yellow'
            end
    end OS_PATCH_CMPLNC_STAT_NM
FROM
    ITR23.SRVR_D SRVR_D join (select to_date('2013-04-24', 'yyyy-mm-dd') as test_date
from
    dual) my_date on 1=1
LEFT JOIN
(SELECT 
       EXCPN_SRVR_NM_LIST_TX
    FROM ITR23.EXCPN_EXITS_D
    WHERE STD_NM= 'Operating System' 
    AND STD_SUBCAT_NM IN ( 'HPUX-Patching','Linux-Patching','Windows-Patching') 
    AND upper(EXCPN_STAT_DN) = 'APPROVED') T on Regexp_Like(t.EXCPN_SRVR_NM_LIST_TX, SRVR_D.SRVR_CI_LGCL_NM || ',') 
    or Regexp_Like(t.EXCPN_SRVR_NM_LIST_TX, ', ' || SRVR_D.SRVR_CI_LGCL_NM) 
    
    )--t
    select 
         t.SRVR_KY
         , case
            when t.OS_VERS_CMPLNC_STAT_NM in ('Green', 'Yellow') then
                'y'
            else
                'n'
         end OS_VERS_CMPLNC_FG
         , case
            when t.OS_PATCH_CMPLNC_STAT_NM in ('Green', 'Yellow') then
                'y'
            else
                'n'
         end OS_VERS_CMPLNC_FG
         , t.OS_VERS_CMPLNC_STAT_NM
         , t.OS_PATCH_CMPLNC_STAT_NM  
         , cl.VERS_SUPP_END_DT
    from
        t
left join
    ITR22.CMPNT_LFECYCL
 on UPPER(cl.CMPNT_TYPE_NM)= 'OS' and cl.CMPNT_VERS_NM = t.VSM_OS_VERS_NM

-- Target
 minus
 select
    srvr_ky
    , OS_VERS_CMPLNC_FG
    , OS_PATCH_CMPLNC_FG
    , OS_VERS_CMPLNC_STAT_NM
    , OS_PATCH_CMPLNC_STAT_NM
    , OS_VERS_END_OF_SUPP_DT

  from
    itr23.SRVR_D
   