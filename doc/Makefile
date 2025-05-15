all: spec.pdf

spec.pdf: spec.md
	pandoc spec.md \
		--from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex \
		--to=latex \
		--output=spec.pdf \
		--pdf-engine=xelatex

