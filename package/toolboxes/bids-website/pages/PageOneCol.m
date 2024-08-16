function html = PageOneCol(props)
% =========================================================================
% Init
html = '';
% =========================================================================
% Start of the HTML code
p = struct();
p.title = props.title;
html = [html, '\n', Header(p)];
% =========================================================================
% Breadcrumbs
html = [html, '\n', Breadcrumb(props.breadcrumb)];
% =========================================================================
% Breadcrumb
html = [html, '\n', '           <div class="row">'];
html = [html, '\n', '               <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12 col-xl-12">'];
html = [html, '\n', '                   <h1>', props.title, '</h1>'];
html = [html, '\n', '                   <p class="lead">', props.subtitle, '</p>'];
for i = 1:length(props.row)
    switch props.row(i).component
        case 'EmbedTxt'
            html = [html, '\n', EmbedTxt(props.row(i).props)]; %#ok<AGROW>
        case 'ImageList'
            html = [html, '\n', ImageList(props.row(i).props)]; %#ok<AGROW>
    end
end
html = [html, '\n', '               </div>'];
html = [html, '\n', '           </div>'];
% =========================================================================
% End of the HTML code
html = [html, '\n', Footer([])];
% =========================================================================
% Write to file
html = sprintf(html);
fid = fopen(props.filename, 'w');
fprintf(fid, '%s', html);
fclose(fid);

end