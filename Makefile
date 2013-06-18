
OBJS = closure.o environment.o main.o objects.o pair.o primitive.o reader.o scheme.o procedure.o macroo.o
DC = gdc

all: clean compile

clean:
	rm -f *.o dscm

compile: $(OBJS)
	$(DC) -w $(OBJS) -o dscm

%.o : %.d
	$(DC) -O -frelease -w -c $< -o $@
