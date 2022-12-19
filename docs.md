## Semigroup
```hs
type Semigroup :: * -> Constraint
class Semigroup a where
  (<>) :: a -> a -> a -- Must Be Associative
  GHC.Base.sconcat :: GHC.Base.NonEmpty a -> a
  GHC.Base.stimes :: Integral b => b -> a -> a
  {-# MINIMAL (<>) #-}
```

## Monoid
```hs
type Monoid :: * -> Constraint
class Semigroup a => Monoid a where
  mempty :: a -- Identity Element
  mappend :: a -> a -> a
  mconcat :: [a] -> a
  {-# MINIMAL mempty #-}
```

## Functors :
A functor is mapping one category to another. More precisely a functor maps some computation into the functorial context using fmap (<$>)
```hs
type Functor :: (* -> *) -> Constraint
class Functor f where
  fmap :: (a -> b) -> f a -> f b
  (<$) :: a -> f b -> f a
  {-# MINIMAL fmap #-}

fmap id = id -- Identity
fmap (f . g) = (fmap f) . (fmap g) -- Composition
```

## Applicative : 
Applicative functor makes it possible to lift functions that are in functorial context in order to compose them. This makes it possible to chain function that need their own context, like I/O

```hs
type Applicative :: (* -> *) -> Constraint
class Functor f => Applicative f where
  pure :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b
  GHC.Base.liftA2 :: (a -> b -> c) -> f a -> f b -> f c
  (*>) :: f a -> f b -> f b
  (<*) :: f a -> f b -> f a
  {-# MINIMAL pure, ((<*>) | liftA2) #-}

pure id <*> v = v -- Identity
pure f <*> pure x = pure (f x) -- Homomophism
u <*> pure y = pure ($ y) <*> u -- Interchange
pure (.) <*> u <*> v <*> w = u <*> (v <*> w) -- Composition 
```

# Monad :
Monad makes it possible to put a value into the monadic context and access that value with a function outside of this context without ever losing the context. This makes it possible to facilitate side-effects and still access the internal values by using the bind operator, we can still reason about monads in a purely functional way even though we can create impure function by combining monads. So, monads allows use to never leave the monadic context, it is impossible for us to accidentally trip over side effects
```hs
type Monad :: (* -> *) -> Constraint
class Applicative m => Monad m where
  (>>=) :: m a -> (a -> m b) -> m b
  (>>) :: m a -> m b -> m b
  return :: a -> m a
  {-# MINIMAL (>>=) #-}

return a >>= f = f a -- Left Identity
m >>= return = m -- Right Identity
(m >>= f) >>= g = m >>= (\x -> f x >>= g) -- Associativity
```