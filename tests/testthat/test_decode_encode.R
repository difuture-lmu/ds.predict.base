context("Ceck if decoding and encoding produces the same model")

test_that("encode produces outpout", {
  mod = lm(Sepal.Width ~ ., data = iris)

  expect_error(encodeObject(mod, sep = 2))
  expect_error(encodeObject(mod, sep = c("-", "xxx")))

  expect_silent({ bin = encodeObject(mod) })
  expect_equal(attr(bin, "sep"), "-")
  expect_equal(names(bin), "mod")
  expect_true(is.character(bin))

  expect_silent({ bin = encodeObject(mod, sep = "xxx") })
  expect_equal(attr(bin, "sep"), "xxx")
  expect_true(is.character(bin))
})

test_that("Decode - encode works properly", {
  assign("mod", lm(Sepal.Width ~ ., data = iris), .GlobalEnv)

  expect_silent({ bin = encodeObject(mod) })
  expect_silent({ mod_b = decodeBinary(bin)})
  expect_equal(mod, mod_b)

  expect_silent({ bin = encodeObject(mod, sep = "xxx") })
  expect_error({ mod_b = decodeBinary(bin)})
  expect_silent({ mod_b = decodeBinary(bin, sep = "xxx")})
  expect_equal(mod, mod_b)
})
