// Force a simple error onto typst
#let fail(err) = {
    (:).at(err)
}
// Converts & rounds a size to centimeters. Should be accurate up to about 1200dpi images (and maybe up to 2400dpi)
#let tocm(size) = {
  return calc.round(size/1cm, digits: 3)
}

// dictionary insertion, returns the modified dict
#let dict_insert(d, key, value, new: false, check: false) = {
  if type(key) == "array" {
    let c = (d,) // This is a recursion tracker
    // We populate the (unfolded) recursive dict
    for i in range(key.len()-1) {
      let k = key.at(i)
      let kn = key.at(i+1)
      // Create the current entry
      if type(kn) == "string" {
        c.push(c.last().at(k, default: (:)))
      } else if type(kn) == "integer" {
        c.push(c.last().at(k, default: ()))
      }
    }
    if new and key.last() in c.last() {
      if check and c.last().at(key.last()) != value {
        return fail("inconsitent values at" + repr(key))
      }
      // We do not overwrite
      return d
    } 
    //Finalize the URD with the value
    c.push(value)
    // Reconstitute (fold) the dict
    for i in range(c.len()-1, 0, step: -1) {
      let k = key.at(i - 1)
      if k == -1 { //Unordered append
        c.at(i - 1).push(c.at(i))
      } else {
        c.at(i - 1).insert(k, c.at(i))
      }
    }
    c.first()
  } else if type(key) == "string" {
    if new and key in d {
      if check and d.at(key) != value {
        return fail("inconsitent values at: " + key)
      }
      // We do not overwrite
      return d
    }
    d.insert(key, value)
    d
  }
}

// formats a dict to json
#let jsonify(dict) = {
  let a = ""
  if type(dict) == "dictionary" {
    a += "{" + dict.pairs().map(i => "\"" + str(i.first()) + "\":" + jsonify(i.last())).join(",") + "}"
  } else if type(dict) == "array" {
    a += "[" + dict.map(v => jsonify(v)).join(",") + "]"
  } else {
    a += repr(dict);
  }
  a
}

#let inl(inl) = "\n" + ("    " * inl)
// formats a dict to json, with padding
#let jsonify_pretty(dict, depth: 0) = {
  let a = ""
  let s = inl(depth+1)
  if type(dict) == "dictionary" {
    a += "{" + s + dict.pairs().map(i => "\"" + str(i.first()) + "\": " + jsonify_pretty(i.last(), depth: depth + 1)).join("," + s) + inl(depth) + "}"
  } else if type(dict) == "array" {
    a += "[" + s + dict.map(v => jsonify_pretty(v, depth: depth + 1)).join("," + s) + inl(depth) + "]"
  } else {
    a += repr(dict);
  }
  a
}