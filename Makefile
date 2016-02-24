DIR_RESULTS = results
DIR_BUILD   = build
DIR_SCRIPTS = scripts

PARSE = $(DIR_SCRIPTS)/parse.pm
GEN_HTML = $(DIR_SCRIPTS)/results-to-html.pm
PUBLISH = $(DIR_SCRIPTS)/git-publish.sh

RESULTS = $(shell ls $(DIR_RESULTS)/*.results)
SCORES = $(addsuffix .scores,$(addprefix $(DIR_BUILD)/,\
	$(basename $(notdir $(RESULTS)))))
HTMLS = $(addsuffix .html,$(basename $(SCORES)))

RESULT_NEWEST = $(shell find $(DIR_RESULTS) | grep ".\+\.results" | \
	sort | tail -n1)
SCORE_NEWEST = $(addsuffix .scores,$(addprefix $(DIR_BUILD)/,\
	$(basename $(notdir $(RESULT_NEWEST)))))
HTML_NEWEST = $(addsuffix .html,$(addprefix $(DIR_BUILD)/,\
	$(notdir $(basename $(SCORE_NEWEST)))))

.PRECIOUS: $(DIR_BUILD)/%.scores

.PHONY: all clean publish

vpath %.results $(DIR_RESULTS)

all: $(HTMLS) $(DIR_BUILD)/index.html

$(DIR_BUILD)/%.scores: %.results
	$(PARSE) $< $@

$(DIR_BUILD)/%.html: $(DIR_BUILD)/%.scores
	$(GEN_HTML) $< $@

$(DIR_BUILD)/index.html: $(HTML_NEWEST)
	cat $< > $@
	echo $<

publish: $(DIR_BUILD)/index.html
	$(PUBLISH) $<

clean:
	rm -rf $(DIR_BUILD)/*
