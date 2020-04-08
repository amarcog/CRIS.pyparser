%Input data

%Enter the name of your CRIS.py results csv file.

CSV_file = 'Your_CRIS.py_results.csv';

%Enter the name of your CRIS.py results txt file.

TXT_file = 'results_counter Your_CRIS.py_results.txt';

%Minimun percentage to assume a pure clone. Allele1 percentage must be
%greater than this value to be classified as homozygotes. Allele 1 and
%Allele2 percentages must be higher than this value/2 to be classified as
%heterozygotes. Otherwise clones will be classified as non-pure genotyped clones.

Purity_Percentage = 80;

%Open csv and txt files


CSV_Table = readtable(CSV_file,'ReadVariableNames',false);



fileID = fopen(TXT_file);
Readsarray = textscan(fileID,'%s', 'Delimiter','\t');
Readsarray = Readsarray{1,:};
fclose(fileID);


%Find and return all number lines (linenumber) that contain the header of the
%allele table of each fastq file

for i = 1:length(Readsarray)
    if contains(char(Readsarray{i,1}),'fastq');
        linenumber(i) = i;
    end
end

linenumber = linenumber(linenumber~=0);

%Define name of the fastq file, total reads and Allele1, Allele2 related vairables.

for i = 1:length(linenumber)
    total_reads(i) = extractBetween(char(Readsarray{linenumber(1,i),1}),'TOTAL:',' ');
    fastq_id{i} = char(extractBefore(char(Readsarray{linenumber(1,i),1}),' TOTAL'));
    Al1_line_number = linenumber(1,i)+1;
    Allele1_seq{i} = char(extractBefore(char(Readsarray{Al1_line_number,1}),' , '));
    Allele1_reads{i} = str2num(extractAfter(char(Readsarray{Al1_line_number,1}),' , '));
    Al2_line_number = linenumber(1,i)+2;
    Allele2_seq{i} = char(extractBefore(char(Readsarray{Al2_line_number,1}),' , '));
    Allele2_reads{i} = str2num(extractAfter(char(Readsarray{Al2_line_number,1}),' , '));
end

total_reads = str2double(total_reads); %just to convert text data into numbers

%Calculate Allele percentajes.

for i = 1:length(linenumber)
    
    Allele1_percentage{i} = (Allele1_reads{1,i}/total_reads(1,i))*100;
    Allele2_percentage{i} = (Allele2_reads{1,i}/total_reads(1,i))*100;
   
end


for i = 1:length(linenumber)
    
    Allele1_percentage{i} = (Allele1_reads{1,i}/total_reads(1,i))*100;
    Allele2_percentage{i} = (Allele2_reads{1,i}/total_reads(1,i))*100;
   
end

%Clasification of zygosity based on clone purity and allele percentages.

for i = 1:length(linenumber)
    
    if (Allele1_percentage{i} > Purity_Percentage)
        
        Genotype{i} = 'HOMOZYGOTE';
        
    elseif (Allele1_percentage{i} > (Purity_Percentage/2)) & ...
                (Allele2_percentage{i} > (Purity_Percentage/2))
        
        Genotype{i} = 'HETEROZYGOTE';
    
    else 
        
        Genotype{i} = 'Non-pure';
        
    end
   
end

%Build final table and write xlsx.

Ourdatatable = table(transpose(fastq_id), ...
transpose(total_reads), ...
transpose(Allele1_seq), ...
transpose(Allele1_reads), ...
transpose(Allele1_percentage), ...
transpose(Allele2_seq), ...
transpose(Allele2_reads), ...
transpose(Allele2_percentage), ...
transpose(Genotype));

Ourdatacell_noheaders = table2cell(Ourdatatable);

Row1_headers = {'fastq_id' ...
'total_reads' ...
'Allele1_seq' ...
'Allele1_reads' ...
'Allele1_percentage' ...
'Allele2_seq' ...
'Allele2_reads' ...
'Allele2_percentage' ...
'Genotype'};

%Concatenate vertically to add headers

our_mixcelldata = {Row1_headers,Ourdatacell_noheaders};
Ourdatacell_withheaders = cat(1,our_mixcelldata{:});

%Concatenate horizontally table from CSV file + Extracted data from
%results_counter...txt file

cris_our_mixcelldata = {CSV_Table,Ourdatacell_withheaders};
Final_data_table = cat(2,cris_our_mixcelldata{:});

writetable(Final_data_table,[extractBefore(CSV_file,'.csv') '.xlsx'], 'WriteVariableNames', false);

clear

disp('Enjoy your new data visualization!!!')
