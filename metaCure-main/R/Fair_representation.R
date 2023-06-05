library(xml2)
library(metadig)
library(ggplot2)
library(broman)
library(dplyr)

dirXML="../checks"

Fair_scores<-function(Res,dir=dirXML){
  checks <- list.files(dir)
  checks<-paste0(dirXML,"/",checks)
  all <- lapply(checks, read_xml)
  names(all) <- checks
  all <- lapply(all, xml_find_all, "type")
  all <- lapply(all, xml_text)
  score=0
  scoreF=0
  countf=0
  scoreA=0
  counta=0
  scoreI=0
  counti=0
  scoreR=0
  countr=0
  for (i in 1:length(Res)){
    if (all[i][[1]]=="findable"){
      countf=countf+1
      if(Res[1][[1]]$value$status=="SUCCESS"){
        score=score+1
        scoreF=scoreF+1
      }
    }
    if (all[i][[1]]=="accessible"){
      counta=counta+1
      if(Res[i][[1]]$value$status=="SUCCESS"){
        score=score+1
        scoreA=scoreA+1
      }
    }
    if (all[i][[1]]=="interoperable"){
      counti=counti+1
      if(Res[i][[1]]$value$status=="SUCCESS"){
        score=score+1
        scoreI=scoreI+1
      }
    }
    if (all[i][[1]]=="reusable"){

      countr=countr+1
      if(Res[i][[1]]$value$status=="SUCCESS"){
        score=score+1
        scoreR=scoreR+1
      }
    }
  }
  scoreF=(scoreF/countf)*100
  scoreA=(scoreA/counta)*100
  scoreI=(scoreI/counti)*100
  scoreR=(scoreR/countr)*100
  score=(score/length(Res))*100
  data=c(scoreF,scoreA,scoreI,scoreR,score)
  barplot(data,names.arg=c("Findable","Accessible","Interoperable","Reusable","Mean Fair Score"),col=c(brocolors("crayons")["Jungle Green"],brocolors("crayons")["Peach"],brocolors("crayons")["Blue Green"],brocolors("crayons")["Cotton Candy"],brocolors("crayons")["Razzmatazz"]))
}



Fair_table<-function(Suite_results,dir=dirXML){
  tab=c()
  checks <- list.files(dir)
  checks<-paste0(dirXML,"/",checks)
  all <- lapply(checks, read_xml)
  names(all) <- checks
  all <- lapply(all, xml_find_all, "type")
  all <- lapply(all, xml_text)

  for (i in 1:length(Suite_results)){
    status=Suite_results[[i]]$value$status[[1]]
    message=Suite_results[[i]]$value$output[[1]][[1]]
    if (status=="FAILURE"){
      tab=rbind(tab,c("Failure",message,all[[i]]))
    }
    if (status=="WARNING"){
      tab=rbind(tab,c("Warning",message,all[[i]]))
    }
    if (status=="SUCCESS"){
      tab=rbind(tab,c("Success",message,all[[i]]))
    }
  }
  tab=data.frame(tab)
  colnames(tab)=c("Status","Message","FAIR")
  tab<-tab[order(tab$Status),]#reorder for visualisation
  return(tab)
}

Fair_pie<-function(Suite_results){
  tab=Fair_table(Suite_results,dir=dirXML)

  tab$Status <- factor(tab$Status,levels = c("Success", "Failure","Warning")) #reorder for visualisation

  # Modify data to use for a graph
  data <- data.frame(
    group=c("Success","Failure","Warning"),
    value=c(table(tab$Status)[['Success']],table(tab$Status)[['Failure']],table(tab$Status)[['Warning']])
  )
  data$group <- factor(data$group,levels = c("Success", "Failure","Warning")) #reorder for visualisation
  # Compute percentages
  data$fraction <- data$value / sum(data$value)

  # Compute the cumulative percentages
  data$ymax <- cumsum(data$fraction)

  # Compute the bottom of each rectangle
  data$ymin <- c(0, head(data$ymax, n=-1))

  # Compute label position
  data$labelPosition <- (data$ymax + data$ymin) / 2

  # Compute a good label
  data$label <- paste0(data$group, "\n ", data$value)

  # Make the plot
  return(ggplot(data, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=group)) +
          geom_rect(color="white") +
          geom_text( x=2, aes(y=labelPosition, label=label, color=group), size=6) + # x here controls label position (inner / outer)
          scale_fill_manual(values=c("#38c535", "#f70e00", "#ff840a"))+
          scale_color_manual(values=c("#38c535", "#f70e00", "#ff840a"))+
          coord_polar(theta="y") +
          xlim(c(-1, 4)) +
          theme_void() +
          theme(legend.position = "none"))
}
