
for y = 2014:2022
  if !isdir(joinpath(@__DIR__, string(y)))
    continue
  end
  for f = readdir(joinpath(@__DIR__, string(y)))
    lines = readlines(joinpath(@__DIR__, string(y), f))
    open(joinpath(@__DIR__, basename(f)), "w") do io
      println(io, "---")
      yaml_ended = false
      for line in lines
        if !startswith(line, "@def")
          if !yaml_ended
            println(io, "---")
            yaml_ended = true
          end
          println(io, line)
          continue
        end
        split_line = split(line, " ")
        field, content = split_line[2], join(split_line[4:end], " ")
        if field in ["title", "date"]
          println(io, "$field: $content")
        elseif field in ["blogpost", "name", "permalink"]
          # ignore
        elseif field == "tags"
          tags = split(content[2:end-1], r",\s*")
          println(io, "tags:")
          for tag in tags
            println(io, "- $tag")
          end
        else
          error("Unknown field $field in $f. Line: $line")
        end
      end
    end
  end
end
