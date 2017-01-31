library(DESeq2)
library("pheatmap")

options(bitmapType="cairo")

#### Start Sample Conditions ####

directory <- "{$self->htseq_dir}"

sampleFiles <- grep(".txt", list.files(directory),value=TRUE)
sampleFiles

#I dont know what this is supposed to be
sampleN <- sub("(*)_*.txt","\\1",sampleFiles)
sampleN <- sub("htseq_(*)","\\1",sampleN)


sampleCondition <- factor(c( {join(",", @{$self->stash->{replDescr}})} ))
sampleCondition

sampleTable <- data.frame(sampleName = sampleN, fileName = sampleFiles, condition = sampleCondition)
sampleTable

#### End Sample Conditions ####

#### Start DDS ####
dds <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,directory = directory,design= ~ condition,ignoreRank=FALSE)
dds

dds <- DESeq(dds)

rld <- rlog(dds)
vsd <- varianceStabilizingTransformation(dds)
rlogMat <- assay(rld)
vstMat <- assay(vsd)

write.table(rlogMat, "{$self->outdir}/deseq2_all_samples_rlog.csv", sep="\t")
write.table(vstMat, "{$self->outdir}/deseq2_all_samples_vst.csv", sep="\t")

#### End  DDS ####

#### Start  DDS Clean  ####

ddsClean <- replaceOutliersWithTrimmedMean(dds)
ddsClean <- DESeq(ddsClean)

#### Start  Rlog and VSD DdsClean  ####

rld2 <- rlog(ddsClean)
vsd2 <- varianceStabilizingTransformation(ddsClean)
rlogMat2 <- assay(rld2)
vstMat2 <- assay(vsd2)

write.table(rlogMat2, "{$self->outdir}/deseq2_all_samples_rlog_replace_outliers.csv", sep="\t")
write.table(vstMat2, "{$self->outdir}/deseq2_all_samples_vst_replace_outliers.csv", sep="\t")

############# Start RLog and VSD ##################

sampleDists <- dist(t(assay(rld)))
library("RColorBrewer")
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- paste(rld$condition, rld$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
png("{$self->outdir}/deseq2_all_samples_rlog_heatmap.png")
rlogHeat <- pheatmap(sampleDistMatrix,clustering_distance_rows=sampleDists,clustering_distance_cols=sampleDists,col=colors)
rlogHeat
dev.off()


sampleDists <- dist(t(assay(vsd)))
library("RColorBrewer")
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- paste(rld$condition, rld$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
png("{$self->outdir}/deseq2_all_samples_vst_heatmap.png")
vstHeat <- pheatmap(sampleDistMatrix,clustering_distance_rows=sampleDists,clustering_distance_cols=sampleDists,col=colors)
vstHeat
dev.off()

############# End RLog and VSD ##################

############# Start plots ##################

{
	my %seen = ();
	my @conditions = keys %{$self->stash->{conditions}};
	$OUT .= "# CONDITIONS: ".join(",", @conditions)."\n";
	my $lim = $self->stash->{lim};

	for (my $i = 0;$i<$lim;$i++){

		for (my $i2 = $0;$i2<$lim;$i2++){
			next if $conditions[$i] eq $conditions[$i2];
			next if exists $seen{$conditions[$i]."_".$conditions[$i2]};
			next if exists $seen{$conditions[$i2]."_".$conditions[$i]};
			$seen{$conditions[$i]."_".$conditions[$i2]} = 1;
			$seen{$conditions[$i2]."_".$conditions[$i]} = 1;

### Start Conditions Plots ###
			$OUT .= "$conditions[$i]VS$conditions[$i2] <- results\(dds,contrast=c\(\"condition\",\"$conditions[$i]\",\"$conditions[$i2]\"\)\)\n";
			$OUT .= "write.table\($conditions[$i]VS$conditions[$i2],\"$self->{outdir}/$conditions[$i]VS$conditions[$i2].csv\", sep=\"\\t\")
png\(\"$self->{outdir}/$conditions[$i]VS$conditions[$i2]\_MAplot.png\"\)
plotMA\($conditions[$i]VS$conditions[$i2], main=\"$conditions[$i]VS$conditions[$i2]\", ylim=c\(-10,10\)\)
dev.off\(\)\n\n";
### End Conditions Plot ###

### Start Transformation Effect Plot ###

            $OUT .=<<EOF
png("$self->{outdir}/$conditions[$i]VS$conditions[$i2]_transformation_plot.png")
par(mai = ifelse(1:4 <= 2, par("mai"),0))
px <- counts(dds)[,1] / sizeFactors(dds)[1]
ord <- order(px)
ord <- ord[px[ord] < 150]
ord <- ord[seq(1,length(ord),length=50)]
last <- ord[length(ord)]
vstcol <- c("blue","black")
matplot(px[ord], cbind(assay(vsd)[,1], log2(px))[ord, ],type="l", lty = 1, col=vstcol, xlab = "n", ylab = "f(n)")
legend("bottomright",legend=c(expression("variance stabilizing transformation"), expression(log[2](n/s[1]))), fill=vstcol)
dev.copy(png,"{$self->{outdir}}/$conditions[$i]VS$conditions[$i2]_DATE-DESeq2_variance_stabilizing.png")
dev.off()
EOF

### End Transformation Effect Plot ###

		}
	}
}

############# End plots ##################


############# Start Normalize Raw Counts ##################

# transform raw counts into normalized values
# DESeq2 has two options:  1) rlog transformed and 2) variance stabilization
# variance stabilization is very good for heatmaps, etc.
#rld <- rlogTransformation(dds, blind=T)
#vsd <- varianceStabilizingTransformation(dds, blind=T)
#
## save normalized values
#
#rlogMat <- assay(rld)
#vsdMat <- assay(vsd)
#write.table(rlogMat, "deseq2_all_samples_rlog.csv", sep="\t")
#write.table(vsdMat, "deseq2_all_samples_vst.csv", sep="\t")

############# End Normalize Raw Counts ##################


############# Start Clustering Analysis ##################

library("gplots")

png("{$self->outdir}/DATE-DESeq2-clustering.png")
distsRL <- dist(t(assay(rld)))
mat <- as.matrix(distsRL)
rownames(mat) <- colnames(mat) <- with(colData(dds),condition)
heatmap.2(mat, trace = "none", margin = c(13, 13))
dev.off()

# Principal components plot
# will show additional clustering of samples
# showing basic PCA function in R from DESeq2 package
# this lacks sample IDs and only broad sense of sample clustering
# its not nice - but it does the job

### Plot PCA

png("{$self->outdir}/DATE-DESeq2_PCA_initial_analysis.png")
print(plotPCA(rld, intgroup = c("condition")))
dev.off()

png("{$self->outdir}/DATE-DESeq2_PCA_initial_analysis_replace_outliers.png")
print(plotPCA(rld2, intgroup = c("condition")))
dev.off()

# scatter plot of rlog transformations between Sample conditions
# nice way to compare control and experimental samples

png("{$self->outdir}/deseq2_scatter_plot.png")
plot(log2(1+counts(dds,normalized=T)),col='black',pch=20,cex=0.3, main='Log2 transformed')
dev.off()

############# End Clustering Analysis ###################

############# Start Heatmap Analysis ###################

# heatmap of data
library("RColorBrewer")
library("gplots")
# 1000 top expressed genes with heatmap.2
select <- order(rowMeans(counts(dds,normalized=T)),decreasing=T)[1:1000]
my_palette <- colorRampPalette(c("blue",'white','red'))(n=1000)

png("{$self->outdir}/deseq2_heatmap_top1k_genes.png")
heatmap.2(assay(vsd)[select,], col=my_palette,
          scale="row", key=T, keysize=1, symkey=T,
          density.info="none", trace="none",
          cexCol=0.6, labRow=F,
          main="TITLE")
dev.off()

# top 2000 genes based on row variance with heatmap3
library(heatmap3)
colsidecolors = c("darkgreen","darkgreen",
 "mediumpurple2","mediumpurple2",
 "mediumpurple2","mediumpurple2",
 "darkgreen","darkgreen",
 "mediumpurple2","mediumpurple2",
 "darkgreen","darkgreen",
 "mediumpurple2","mediumpurple2",
 "mediumpurple2","mediumpurple2")
rv <- rowVars(assay(vsd))
select <- order(rv, decreasing=T)[seq_len(min(2000,length(rv)))]
my_palette <- colorRampPalette(c("blue", "white", "red"))(1024)

png("{$self->outdir}/deseq2_heatmap_top3k_genes_based_on_row_variance.png")

heatmap3(assay(vsd)[select,],col=my_palette,
 labRow = F,cexCol = 0.8,margins=c(6,6))
dev.off()

sessionInfo()

############# End Heatmap Analysis ##################
