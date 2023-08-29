all: example.ipynb

clean:
	rm example.ipynb

SNIPPETS := chi-config.md reserve-resources.md configure-resources.md offload-off.md log-in.md delete-slice.md
example.ipynb: $(SNIPPETS) example.md
	pandoc --wrap=none \
                -i chi-config.md \
				example.md \
				configure-resources.md \
				offload-off.md \
				log-in.md \
				delete-slice.md \
                -o example.ipynb  