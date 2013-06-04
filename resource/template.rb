mapping("") do

# declare table will be used
#
# e.g. :
# declare_target_table 'target_table', :t
# declare_source_table 'source_table1', :src1
# declare_source_table "select * from source_table2 where lgcl_del_fg = 'n'", :src2
# declare_cte_as "select * from source_table3", :src3




# define mappings
#
# e.g. :
#
# mp t.pk, src1.pk
#
# m t.some_ky, do
# 	left_join src2, 'src1.fk = src2.pk'
# 	if src2.some_ky.nil?
# 		0 # Not Found
# 	else
# 		src2.some_ky
# 	end
# end


# Refer to "https://github.com/piecehealth/ETLTester" for more information.
end