library(hexbin)

rtdt1 = D[run==1, .(rt, dt)]
plot(rtdt1, pch=".")

h = hexbin(rtdt1, xbins=100, ID=T)
plot(h)

z = hsmooth(h, c(10,5,1))
plot(z)
z = hsmooth(h, 3:1)
plot(z)


library(ggplot2)

ggplot(D, aes(x=rt, y=dt)) +
  geom_hex() +
  facet_wrap(~run) +
  theme_classic()
