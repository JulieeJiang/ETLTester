#require '../../../lib/etltester'

#test_mapping = 
mapping("L3_SRVR_D") do

	declare_target_table 'itr23.srvr_d', 't'

	declare_source_table 'itr23.srvr_d', 'srvr_d'

	mp t.srvr_ky, srvr_d.srvr_ky
	
	m t.os_vers_cmplnc_stat_nm do
		if srvr_d.os_vers_end_of_supp_dt.nil?
            'Red'
        else
            sysdate = params[:sysdate].to_time
            month_def = srvr_d.os_vers_end_of_supp_dt.month_between sysdate
            case 
            when month_def > 24
                'Green'
            when month_def <= 24 && month_def > 12
                'Yellow'
            when month_def <= 12 && month_def > -12
                'Red'
            when month_def <= -12
                'Purple'
            end
        end
	end

    define_variable :exception_list do
        exceptions = ETLTester::Util::DBConnection::get_data_from_db({type: :oracle, address: "ITR2ITG_DEDICATED", user: "infr", password: "INFR_INFR_2011.bb"},
         %Q{
            SELECT EXCPN_SRVR_NM_LIST_TX 
            FROM ITR23.EXCPN_EXITS_D
            WHERE STD_NM= 'Operating System' 
            AND STD_SUBCAT_NM IN ( 'HPUX-Patching','Linux-Patching','Windows-Patching') 
            AND upper(EXCPN_STAT_DN) = 'APPROVED'
        })[0][0]
        exceptions.split(',')
    end

    m t.os_patch_cmplnc_stat_nm do
        if srvr_d.srvr_patch_rqr_ind.nil?
            'Red'
        else
            if srvr_d.srvr_patch_rqr_ind.upcase == 'N'
                'Green'
            else
                if variable[:exception_list].include? srvr_d.srvr_ci_lgcl_nm
                    'Yellow'
                else
                    'Red'
                end
            end
        end
    end

    m t.os_vers_cmplnc_fg do
        if ['Green', 'Yellow'].include? row[:os_vers_cmplnc_stat_nm]
            'y'
        else
            'n'
        end
    end

    m t.os_patch_cmplnc_fg do
        if ['Green', 'Yellow'].include? row[:os_patch_cmplnc_stat_nm]
            'y'
        else
            'n'
        end
    end
	
    m t.os_vers_end_of_supp_dt do
        declare_source_table <<-SQL, :lkp_supp_end_dt
            SELECT distinct CMPNT_VERS_NM, VERS_SUPP_END_DT FROM ITR22.CMPNT_LFECYCL WHERE UPPER(CMPNT_TYPE_NM)= 'OS'
            and LGCL_DEL_FG = 'n'
        SQL
        left_join lkp_supp_end_dt, 'lkp_supp_end_dt.CMPNT_VERS_NM = SRVR_D.VSM_OS_VERS_NM'
        lkp_supp_end_dt.vers_supp_end_dt
    end
    #puts @source_sql_generator.generate_sql

end

# ETLTester::Util::Configuration.set_project_path File.dirname(File.realpath(__FILE__)) + '/..'
# driver = ETLTester::Framework::Driver.new

# driver.mapping = test_mapping
# driver.run :smart