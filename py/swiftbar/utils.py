def ft_print(text: str, **kwargs: object):
  params = ' '.join(['%s=%s' % (key, value) for key, value in kwargs.items()])
  print('%s | %s' % (text, params) if kwargs.items() else text)
