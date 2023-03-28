#CCS reads quality and length plot
#Mojtaba Jahani October 2020
library(tidyverse)
library(data.table)
library(hexbin)
library(ggExtra)
library(ggpubr)

args = commandArgs(trailingOnly = TRUE)

SORTED_MAPQ <- as.character(args[1])
READ_LENGTH <- as.character(args[2])
NAME <- as.character(args[3])

fread(SORTED_MAPQ ,sep = "\t",header = F) %>%
  filter(!grepl("^@",V1)) %>% 
  mutate(np=as.numeric(gsub("np:i:","",V2))) %>% 
  mutate(Q=-10 * log10( #calculate phred quality score
    1-as.numeric(
      gsub("rq:f:","",V3)
      )
    )
    ) %>%
  select(name=V1,
         np,
         Q) %>%
  full_join(.,
            fread(READ_LENGTH ,sep = "\t",header = F) %>% 
              rename(name=V1,
                     length=V2)) -> np_Q_length

data.frame(Sequence = NAME,
           N.reads = nrow(np_Q_length),
           Min.passes = min(np_Q_length$np),
           Max.passes = max(np_Q_length$np),
	   Mean.passes = mean(np_Q_length$np),
           Min.Quality = min(np_Q_length$Q),
           Max.Quality = max(pull(filter(select(np_Q_length,Q),!is.infinite(Q)),Q)),
 	   Mean.Quality = mean(pull(filter(select(np_Q_length,Q),!is.infinite(Q)),Q)),
           Min.length = min(np_Q_length$length),
           Max.length = max(np_Q_length$length),
           Mean.length= mean(np_Q_length$length),
           Total.length = sum(np_Q_length$length),
	   Coverage = (sum(np_Q_length$length))/876147649) %>%
  fwrite(paste0(NAME,".summary.stat"),sep = "\t",col.names = T)
   
ggplot(np_Q_length, aes(x=length, y=Q)) +
  geom_hex(bins = 75) +
  geom_point(col="transparent") +
  scale_fill_continuous(type = "viridis") +
  theme(legend.position = c(0.90, 0.8),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", colour = "black")) +
  labs(x ="CCS read length (bp)", y = "CCS read accuracy (Phred)") -> P

ggMarginal(P, type="histogram",fill = "slateblue") -> P1

ggplot(np_Q_length, aes(x=as.factor(np), y=Q)) + 
  geom_boxplot(outlier.shape = NA) +
  theme(panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", colour = "black")) +
  labs(x ="Subreads (Number of passess)", y = "CCS read accuracy (Phred)") -> P2

ggarrange(P2,P1, 
          nrow = 2,
          heights = c(0.7,2)) -> P3

ggsave(paste0(NAME,".pdf"),P3)

rm(np_Q_length,P,P1,P2,P3)

