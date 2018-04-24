.ONESHELL:

EXPORTDIR = ~/oCS/export
EXPORTNAME = CS113Lab7

LTXPRE = ~/pp/bin

MKDIR = mkdir -p
RM = rm -f -r
CP = cp -f

#Directories
SRCDIR = src
OBJDIR = build
OUTDIR = out

SMLEXTRCT = $(OBJDIR)/lab.sml

.PHONY: all c asm pdf sml pp export

all: pdf

pdf: $(OUTDIR)/lab.pdf

c: $(OUTDIR)/labc

asm: $(OUTDIR)/labasm

sml: $(SMLEXTRCT) $(OUTDIR)/
	@echo Run ASM
	@poly < $(OBJDIR)/lab.sml > $(OUTDIR)/output.sml

pp: $(SMLEXTRCT) $(OUTDIR)/
	@echo Running Proof Power
	@$(LTXPRE)/pp -d hol < $(OBJDIR)/lab.pp > $(OUTDIR)/output.pp

export: pdf
	@$(MKDIR) $(EXPORTDIR)
	$(CP) $(OUTDIR)/lab.pdf $(EXPORTDIR)/$(EXPORTNAME).pdf
	tar zcvf ../temp ** --exclude=build --exclude=out
	cd ..
	$(CP) temp $(EXPORTDIR)/$(EXPORTNAME).tgz
	rm temp

#end phony

$(OUTDIR)/lab.pdf: $(OBJDIR)/lab.dvi $(OUTDIR)/
	@echo Translate to PDF
	@cd $(OUTDIR)
	@dvipdf ../$(OBJDIR)/lab.dvi

$(OBJDIR)/lab.dvi: $(OBJDIR)/lab.tex
	@cd $(OBJDIR)
	@echo Suppressing output - Piping to $(OBJDIR)/output
	@echo First pass of generation
	@$(LTXPRE)/pptexenv latex lab.tex > output
	@echo Second Pass
	@echo ------------SECOND PASS----------------- >>output
	@$(LTXPRE)/pptexenv latex lab.tex >> output

$(OBJDIR)/lab.tex: $(SRCDIR)/lab.doc $(OBJDIR)/
	@cd $(OBJDIR)
	@echo Extract lab.doc into lab.tex
	@$(LTXPRE)/doctex ../$(SRCDIR)/lab.doc

#Anything that needs extraction from the lab doc will just look at lab.asm
$(SMLEXTRCT): $(OBJDIR)/ $(SRCDIR)/lab.doc
	@cd $(OBJDIR)
	echo Extracting files
	$(LTXPRE)/docsml ../$(SRCDIR)/lab.doc

$(OUTDIR)/labc: $(SMLEXTRCT) $(OUTDIR)/
	@echo Compile C
	@gcc -g $(OBJDIR)/lab.c -o $(OUTDIR)/labc

$(OUTDIR)/labasm: $(OBJDIR)/labasm.o $(OUTDIR)/
	@echo Linking ASM
	@ld $(OBJDIR)/labasm.o -o $(OUTDIR)/labasm 

$(OBJDIR)/labasm.o: $(SMLEXTRCT) $(OBJDIR)/
	@echo Build Object files for ASM
	@as -g $(OBJDIR)/lab.s -o $(OBJDIR)/labasm.o

#make sure the directory exists
$(OBJDIR)/:
	@$(MKDIR) $(OBJDIR)

$(OUTDIR)/:
	@$(MKDIR) $(OUTDIR)

clean:
	@$(RM) build
	@$(RM) out


