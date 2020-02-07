import os, system, strutils, strformat, sequtils, algorithm, memfiles, parseopt, tables

type
  Gift = tuple
    name: string
    price: int

type
  Solution = tuple
    first: Gift
    second: Gift

proc `<`(a, b: Gift): bool =
  a.price < b.price

proc parseGifts(fileName : string) : seq[Gift] =
  var gifts : seq[Gift]

  for gift in fileName.readFile.splitLines:
    let splitted = gift.split(",")
    if splitted.len == 2:
      gifts &= (splitted[0].strip, splitted[1].strip.parseInt)
  gifts

proc chooseGifts3(fileName : string, targetPrice : int) : Solution =
  # version that uses two indexes into the array and progressively moves them towards each other
  var gifts : seq[Gift] = fileName.parseGifts

  var low : int
  var high = gifts.len - 1
  var currentMax : int

  while low < high:
    var sum = gifts[low].price + gifts[high].price
    if sum == targetPrice:
      # handle the case where they're exact, and break early
      result = (gifts[low], gifts[high])
      break
    elif sum < targetPrice:
      # the sum was less than the target price
      # keep it as a candidate,
      # but keep moving the low index up to try and find a better one
      if sum > currentMax:
        currentMax = sum
        result = (gifts[low], gifts[high])
      # the logic here is that it's impossible for anything lower
      # to sum to something higher than what we already have
      # since it would be a + b vs a + c where c > b and a < c
      # so we can safely ignore entries lower while still moving the high index downwards
      low += 1
    else:
      # skip ones that are too large to fit
      high -= 1

proc chooseGifts2(fileName : string, targetPrice : int) : Solution =
  # iterate over the gifts and then use binary search
  # with a custom comparator to find the closest element that sums to <= target
  # keep track of the current max sum and replace if we find a greater one

  var gifts : seq[Gift] = fileName.parseGifts
  let buckets = gifts.zip(gifts[1..^1]).reversed
  var currentMax : int = 0

  for gift in gifts:
    proc compareGifts(giftPair : tuple[a : Gift, b : Gift], target : int) : int =
      if giftPair.a == gift:
        # ignore the gift that we are already looking at
        # this avoids the problem of duplicates
        if target >= giftPair.b.price:
          return 1
        else:
          return -1

      if target >= giftPair.b.price:
        return 1

      if target < giftPair.a.price:
        return -1

      if (target >= giftPair.a.price) and (target < giftPair.b.price):
        return 0

    if gift.price >= targetPrice:
      continue

    let candidateIndex = buckets.binarySearch(targetPrice - gift.price, compareGifts)

    if (candidateIndex == -1):
      continue

    if currentMax < (gift.price + buckets[candidateIndex].a.price):
      currentMax = gift.price + buckets[candidateIndex].a.price
      result = (gift, buckets[candidateIndex].a)

    assert(currentMax <= targetPrice)
  
proc chooseGifts1(fileName : string, targetPrice : int) : Solution =
  # solution based on repeatedly scanning the sequence of gifts
  # not the most optimal solution
  var currentMax : int = 0 
  var currentGift : Gift
  var gifts : seq[Gift] = fileName.parseGifts.reversed

  while gifts.len > 0:
    currentGift = gifts[0]

    # if the current price is greater than the target price
    # then it's impossible it fits, move to the next smallest
    if currentGift.price > targetPrice:
      gifts = gifts[1..^1]
      continue

    # loop over all gifts after the current one
    for gift in gifts[1..^1]:

      # if the currentGift plus the one after it is greater than our current max
      # then there's no need to look at other pairs, move currentGift to the next one
      # and keep trying
      if (currentGift.price + gift.price) < currentMax:
        break

      # if the currentGift plus the one we're looking at equals the target exactly
      # then we're done, break
      if currentGift.price + gift.price == targetPrice:
        result = (currentGift, gift)
        break

      # if the currentGift plus the one we're looking at is less than the target
      # and greater than the currentMax, then it becomes our new max
      if ((currentGift.price + gift.price) < targetPrice) and ((currentGift.price + gift.price) > currentMax):
        result = (currentGift, gift)
        currentMax = currentGift.price + gift.price

    # re-assign gifts to a smaller slice of gifts each time we've processed one
    gifts = gifts[1..^1]

proc choose3Gifts(fileName : string, targetPrice : int) : tuple[a : Gift, b: Gift, c: Gift] =
  # Implementation of the 3 gift sum challenge
  # The algorithm is quadratic
  # The basic idea is similar to the chooseGifts3 proc but instead there is an outer for loop
  # And we use the rest of the gifts as our search space

  var gifts : seq[Gift] = fileName.parseGifts
  var sum : int
  var currentMax : int
  var start, ending : int

  for i in countup(0, gifts.len - 2):
    # test the rest of them using the same algorithm as before
    start = i + 1
    ending = gifts.len - 1

    while start < ending:
      sum = gifts[start].price + gifts[ending].price + gifts[i].price
      if sum == targetPrice:
        # handle the case where they're exact, and break early
        return (gifts[i], gifts[start], gifts[ending])
      elif sum < targetPrice:
        # the sum was less than the target price
        # keep it as a candidate,
        # but keep moving the low index up to try and find a better one
        if sum > currentMax:
          currentMax = sum
          result = (gifts[i], gifts[start], gifts[ending])
        start += 1
      else:
        # skip ones that are too large to fit
        ending -= 1
    assert(currentMax <= targetPrice)

proc outputSolution(version : string,
                    filename : string,
                    target : string) : string =
  var solution : Solution

  case version:
    of "1":
      solution = filename.chooseGifts1(target.parseInt)
    of "2":
      solution = filename.chooseGifts2(target.parseInt)
    of "3":
      solution = filename.chooseGifts3(target.parseInt)
    else:
      echo fmt"There is no version {version}"
      quit(1)

  # if both are set to 0 it means no solution was found
  # these are just the default initialized values
  if solution.first.price <= 0 or solution.second.price <= 0:
    "Not possible"
  else:
    let gifts = [solution.first, solution.second].sorted
    fmt"{gifts[0].name} {gifts[0].price}, {gifts[1].name} {gifts[1].price}"

when isMainModule:
  var args = initOptParser(commandLineParams().join(" "))
  var params = initTable[string, string]()
  let validArgs = @["v", "version", "f", "filename", "t", "target"]
  var currentKey : string

  while true:
    args.next()
    case args.kind
      of cmdEnd: break
      of cmdShortOption, cmdLongOption:
        if args.val == "":
          continue
        else:
          if validArgs.contains(args.key):
            params[args.key] = args.val
      of cmdArgument:
        if validArgs.contains(currentKey):
          params[currentKey] = args.val

  if params.hasKey("v"):
    params["version"] = params["v"]
  if params.hasKey("f"):
    params["filename"] = params["f"]
  if params.hasKey("t"):
    params["target"] = params["t"]

  if params.hasKey("version") and params["version"] == "4":
    let gifts = params["filename"].choose3Gifts(params["target"].parseInt)
    if [gifts.a.price, gifts.b.price, gifts.c.price].all(proc (p : int) : bool = p == 0):
      echo "Not possible"
    else:
      echo fmt"{gifts.a.name} {gifts.a.price}, {gifts.b.name} {gifts.b.price}, {gifts.c.name} {gifts.c.price}"
    quit(0)

  if not (params.hasKey("version") and
          params.hasKey("filename") and
          params.hasKey("target")):
    echo "Invalid parameters"
    quit(1)

  echo outputSolution(params["version"], params["filename"], params["target"])
