function issurf = conn_surf_dimscheck(dim)
if isstruct(dim), dim=dim(1).dim; end
issurf = isequal(sort(dim),sort(conn_surf_dims(8).*[1 1 2]))||isequal(sort(dim),sort(conn_surf_dims(8).*[1 2 1]));
