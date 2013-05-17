require '../../lib/etltester'

test_mapping = mapping("L3_SRVR_D") do

	declare_target_table 'itr23.srvr_d', 't'

	declare_source_table 'itr23.srvr_d', 'srvr_d'

	
	declare_cte_as <<-SQL, 'lkp'
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
    ITR23.SRVR_D SRVR_D join (select to_date('#{params[:sysdate]}', 'yyyy-mm-dd') as test_date
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
    )
	SQL


	mp t.srvr_ky, srvr_d.srvr_ky
	
	m t.os_vers_cmplnc_stat_nm do
		link lkp, 'lkp.srvr_ky = srvr_d.srvr_ky'
		lkp.os_vers_cmplnc_stat_nm
	end
	puts @source_sql_generator.generate_sql
end

