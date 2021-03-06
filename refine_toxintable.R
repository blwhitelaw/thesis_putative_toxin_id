rm(list=ls())

toxin_1 <- read.delim(file.choose(), header = T, sep = "\t")
toxin_6 <- read.delim(file.choose(), header = T, sep = "\t")

toxin <- rbind(toxin_1, toxin_6)
toxin <- toxin[!duplicated(toxin[c("orf_id","transcript_id", "peptide")]),]

countCharOccurrences <- function(char, s) {
    s2 <- gsub(char,"",s)
    return (nchar(s) - nchar(s2))
}

refine_table <- function(data, length, pro_prob, cys, tis) {

	
    data <- data[which(data$pep_length < length),]
    data <- data[which(data$protein_probability > pro_prob),]
    data <- data[which(data$tissue == tis),]
    data <- data[which(data$has_signalp == "YES"),]
    
    data$peptide <- as.character(data$peptide)
	data <- cbind(data, cystine_count = countCharOccurrences("C", data$peptide))
	data <- data[which(data$cystine_count > cys),]
    data <- cbind(data, cys_percentage = data$cystine_count / data$pep_length)
    data <- data[which(data$cys_percentage > 0.02),]


}

ref_toxin_table <- refine_table(toxin, 500, 0.99, 3, "PSG")

all_0.99 <- toxin[which(toxin$protein_probability > 0.99)]


get_fasta_n_tab <- function(ref_toxin_table, file_name) {

library (seqinr)

setwd("~/Desktop")

write.table(ref_toxin_table, paste(c(file_name, ".txt"), collapse = ""), sep = "\t", col.names = T, row.names = F)

ref_toxin_table$accession <- paste(ref_toxin_table$accession, ref_toxin_table$uniprot_accession, ref_toxin_table$protein_name, ref_toxin_table$go_terms, sep= "   ")

write.fasta(sequences = as.list(ref_toxin_table$peptide), 
	names = ref_toxin_table[["accession"]], 
	file.out = paste(c(file_name, ".fasta"), collapse = ""), open = "w", nbchar = 80)

}


#get_fasta_n_tab(ref_toxin_table, "bro_psg_tox_list")
#get_fasta_n_tab(all_0.99, "bro_0.99")


