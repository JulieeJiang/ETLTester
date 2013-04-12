require 'dbi'

begin

	dbh = DBI.connect("DBI:OCI8:ITR2ITG_DEDICATED", "infr", "INFR_INFR_2011.bb")
	rs = dbh.prepare "select * from itr23.asset_d aa where rownum <= 10"
	rs.execute
	while row = rs.fetch
		puts row.to_a
	end
ensure
	dbh.disconnect unless dbh.nil?
end