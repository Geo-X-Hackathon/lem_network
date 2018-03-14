function [ OUTARGdatacube, OUTARGmetadata, OUTARGdem ] = import_elevation( INARGdatapath )
%IMPORT_ELEVATION Import CAESAR data as datacube
%   [ DATACUBE, MEATADATA, DEM ] = import_elevation( DATAPATH )
%   DATACUBE     3D matrix of all DEM time slices
%   METADATA    struct with meta information for each timeslice
%   DEM          GRIDobj of t=0 DEM     (w/o topotoolbox: 2D matrix)

    %INARGdatapath = '../CAESAR_data/D4/';

    % CEASAR specific file masks:
    inputfile_mask = 'elev.dat*.txt';
    fileheader_length = 6;
    filedlm = [' '];
    
    
    
    % parse input path:
    [datapath, ~, ~] = fileparts (INARGdatapath);
    
    inputfiles = strcat(datapath, filesep, inputfile_mask );
    
    %load file names in struct
    files = dir( inputfiles );
    
    if (isempty(files)) 
        error(['Current directory: ' pwd '\n%s'], ['No files found in ' inputfiles]);
    end %end if

    if (exist('GRIDobj')~=2) %topotoolbox exists
        warning('Topotoolbox not available. GRIDobj will not be created.')
    end %end if

    
    numfiles = size(files,1);
    
    %load every file and write it into data cube matrix
    for i=1:numfiles
        %get file name and path
        filenamei = files(i).name;
        folderi = files(i).folder;
        fullfilei = strcat(folderi, filesep, filenamei);
        %preserve individual file id and write it into variable
        fileidi = strjoin(strsplit(filenamei,strsplit(inputfile_mask,'*')),'');
        
        %topotoolbox exists:
        if (exist('GRIDobj')==2) 
            DEMi=GRIDobj(fullfilei);
            datai=DEMi.Z;
            if i==1
                OUTARGdem = DEMi;
            end %end if
        
        %topotoolbox does not exist    
        else 
          % load header
          fid = fopen(fullfilei,'r');
          clear lll
             fileheaderi = struct();
             for ii = 1:fileheader_length
            	ll = fgetl(fid);
            	lll = strsplit(ll, filedlm);
                 fileheaderi.(cell2mat(lll(1)))=str2num(cell2mat(lll(2)));
             end %end for ii
          fclose(fid);
          datai = dlmread(fullfilei,filedlm,fileheader_length,0);
           % remove NaN:
          datai(find(datai==fileheaderi.NODATA_value)) = NaN;
          OUTARGmetadata(i).header = fileheaderi;
          if i==1
              OUTARGdem = datai;
          end %end if

        end %end if


        OUTARGmetadata(i).filename = filenamei;
        OUTARGmetadata(i).folder = folderi;
        OUTARGmetadata(i).fullfile = fullfilei;
        OUTARGmetadata(i).fileid = fileidi;
%         OUTARGmetadata(i).header = fileheaderi;

        OUTARGdatacube(:,:,i) = datai;
        
 
    end %end for i
    
    
    end % end function

