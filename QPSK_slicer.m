%%%%%%原书自带
% function x_sliced = QPSK_slicer(x)
% sq05 = 1/sqrt(2);
% jsq05 = 1j*sq05;
% for i = 1:length(x)
%     if imag(x(i))>real(x(i)) 
%         if imag(x(i))>-real(x(i)) 
%             x_sliced(i) =jsq05;
%         else
%             x_sliced(i) =-jsq05;
%         end
%     else
%         if imag(x(i))>-real(x(i)) 
%              x_sliced(i) =jsq05;
%         else
%             x_sliced(i) =-jsq05;
%         end
%     end
% end

%%%%自己编写
function x_sliced = QPSK_slicer(x)
    for i = 1:length(x)
       if real(x(i))>0 && imag(x(i))>0
            x_sliced(i) = 1/sqrt(2) + 1j*(1/sqrt(2));
       elseif real(x(i))<0 && imag(x(i))>0
            x_sliced(i) = -1/sqrt(2) + 1j*(1/sqrt(2));
       elseif real(x(i))<0 && imag(x(i))<0
            x_sliced(i) = -1/sqrt(2) - 1j*(1/sqrt(2));  
       elseif real(x(i))>0 && imag(x(i))<0
            x_sliced(i) = 1/sqrt(2) - 1j*(1/sqrt(2));
       end
    end
end